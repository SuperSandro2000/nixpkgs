{
  lowPrio,
  newScope,
  pkgs,
  targetPackages,
  lib,
  stdenv,
  libxcrypt,
  substitute,
  replaceVars,
  fetchFromGitHub,
  fetchpatch,
  fetchpatch2,
  overrideCC,
  wrapCCWith,
  wrapBintoolsWith,
  buildPackages,
  buildLlvmTools, # tools, but from the previous stage, for cross
  targetLlvmLibraries, # libraries, but from the next stage, for cross
  targetLlvm,
  # This is the default binutils, but with *this* version of LLD rather
  # than the default LLVM version's, if LLD is the choice. We use these for
  # the `useLLVM` bootstrapping below.
  bootBintoolsNoLibc ? if stdenv.targetPlatform.linker == "lld" then null else pkgs.bintoolsNoLibc,
  bootBintools ? if stdenv.targetPlatform.linker == "lld" then null else pkgs.bintools,
  darwin,
  gitRelease ? null,
  officialRelease ? null,
  monorepoSrc ? null,
  version ? null,
  patchesFn ? lib.id,
  # Allows passthrough to packages via newScope. This makes it possible to
  # do `(llvmPackages.override { <someLlvmDependency> = bar; }).clang` and get
  # an llvmPackages whose packages are overridden in an internally consistent way.
  ...
}@args:

assert lib.assertMsg (lib.xor (gitRelease != null) (officialRelease != null)) (
  "must specify `gitRelease` or `officialRelease`"
  + (lib.optionalString (gitRelease != null) " — not both")
);

let
  monorepoSrc' = monorepoSrc;

  metadata = rec {
    # Import releaseInfo separately to avoid infinite recursion
    inherit
      (import ./common-let.nix {
        inherit (args)
          lib
          officialRelease
          version
          ;
      })
      releaseInfo
      ;
    inherit (releaseInfo) release_version version;
    inherit
      (import ./common-let.nix {
        inherit
          lib
          fetchFromGitHub
          release_version
          officialRelease
          version
          ;
      })
      llvm_meta
      monorepoSrc
      ;
    src = monorepoSrc;
    versionDir =
      (builtins.toString ../.)
      + "/${lib.versions.major release_version}";
    getVersionFile =
      p:
      builtins.path {
        name = builtins.baseNameOf p;
        path =
          let
            patches = args.patchesFn (import ./patches.nix);

            constraints = patches."${p}" or null;
            matchConstraint =
              { ... }:
              true;

            patchDir =
              toString
                (
                  if constraints == null then
                    { path = metadata.versionDir; }
                  else
                    (lib.findFirst matchConstraint { path = metadata.versionDir; } constraints)
                ).path;
          in
          "${patchDir}/${p}";
      };
  };

  tools = lib.makeExtensible (
    tools:
    let
      callPackage = newScope (tools // args // metadata);
      clangVersion = metadata.release_version;
      mkExtraBuildCommands0 =
        cc:
        ''
          rsrc="$out/resource-root"
          mkdir "$rsrc"
          echo "-resource-dir=$rsrc" >> $out/nix-support/cc-cflags
        ''
        + (
            ''
              ln -s "${lib.getLib cc}/lib/clang/${clangVersion}/include" "$rsrc"
            ''
        );
      mkExtraBuildCommandsBasicRt =
        cc:
        mkExtraBuildCommands0 cc
        + ''
          ln -s "${targetLlvmLibraries.compiler-rt-no-libc.out}/lib" "$rsrc/lib"
        '';
      mkExtraBuildCommands =
        cc:
        mkExtraBuildCommands0 cc
        + ''
          ln -s "${targetLlvmLibraries.compiler-rt.out}/lib" "$rsrc/lib"
          ln -s "${targetLlvmLibraries.compiler-rt.out}/share" "$rsrc/share"
        '';

      bintoolsNoLibc' = if bootBintoolsNoLibc == null then tools.bintoolsNoLibc else bootBintoolsNoLibc;
      bintools' = if bootBintools == null then tools.bintools else bootBintools;
    in
    {
      libllvm = callPackage ./llvm {
      };

      # `llvm` historically had the binaries.  When choosing an output explicitly,
      # we need to reintroduce `outputSpecified` to get the expected behavior e.g. of lib.get*
      llvm = tools.libllvm;

      libclang = callPackage ./clang {
      };

      clang-unwrapped = tools.libclang;

      llvm-manpages = lowPrio (
        tools.libllvm.override {
          enableManpages = true;
          python3 = pkgs.python3; # don't use python-boot
        }
      );

      # pick clang appropriate for package set we are targeting
      clang =
        if stdenv.targetPlatform.libc == null then
          tools.clangNoLibc
        else if stdenv.targetPlatform.useLLVM or false then
          tools.clangUseLLVM
        else if (pkgs.targetPackages.stdenv or args.stdenv).cc.isGNU then
          tools.libstdcxxClang
        else
          tools.libcxxClang;

      libstdcxxClang = wrapCCWith rec {
        cc = tools.clang-unwrapped;
        # libstdcxx is taken from gcc in an ad-hoc way in cc-wrapper.
        libcxx = null;
        extraPackages = [ targetLlvmLibraries.compiler-rt ];
        extraBuildCommands = mkExtraBuildCommands cc;
      };

      libcxxClang = wrapCCWith rec {
        cc = tools.clang-unwrapped;
        libcxx = targetLlvmLibraries.libcxx;
        extraPackages = [ targetLlvmLibraries.compiler-rt ];
        extraBuildCommands = mkExtraBuildCommands cc;
      };

      # Below, is the LLVM bootstrapping logic. It handles building a
      # fully LLVM toolchain from scratch. No GCC toolchain should be
      # pulled in. As a consequence, it is very quick to build different
      # targets provided by LLVM and we can also build for what GCC
      # doesn’t support like LLVM. Probably we should move to some other
      # file.

      clangUseLLVM = wrapCCWith (
        rec {
          cc = tools.clang-unwrapped;
          libcxx = targetLlvmLibraries.libcxx;
          bintools = bintools';
          extraPackages = [
            targetLlvmLibraries.compiler-rt
          ]
          ++ lib.optionals (!stdenv.targetPlatform.isWasm && !stdenv.targetPlatform.isFreeBSD) [
            targetLlvmLibraries.libunwind
          ];
          extraBuildCommands = mkExtraBuildCommands cc;
        }
        // lib.optionalAttrs (lib.versionAtLeast metadata.release_version "14") {
          nixSupport.cc-cflags = [
            "-rtlib=compiler-rt"
            "-Wno-unused-command-line-argument"
            "-B${targetLlvmLibraries.compiler-rt}/lib"
          ]
          ++ lib.optional (
            !stdenv.targetPlatform.isWasm && !stdenv.targetPlatform.isFreeBSD
          ) "--unwindlib=libunwind"
          ++ lib.optional (
            !stdenv.targetPlatform.isWasm
            && !stdenv.targetPlatform.isFreeBSD
            && stdenv.targetPlatform.useLLVM or false
          ) "-lunwind"
          ++ lib.optional stdenv.targetPlatform.isWasm "-fno-exceptions";
          nixSupport.cc-ldflags = lib.optionals (
            !stdenv.targetPlatform.isWasm && !stdenv.targetPlatform.isFreeBSD
          ) [ "-L${targetLlvmLibraries.libunwind}/lib" ];
        }
      );
    }
  );

  libraries = lib.makeExtensible (
    libraries:
    let
      callPackage = newScope (
        libraries
        // buildLlvmTools
        // args
        // metadata
        # Previously monorepoSrc was erroneously not being passed through.
        // lib.optionalAttrs (lib.versionOlder metadata.release_version "14") { monorepoSrc = null; } # Preserve a bug during #307211, TODO: remove; causes llvm 13 rebuild.
      );
    in
    (
      {
        stdenv = overrideCC stdenv buildLlvmTools.clang;

        libcxx = callPackage ./libcxx (
          {
            stdenv =
              if stdenv.hostPlatform.isDarwin then
                overrideCC darwin.bootstrapStdenv buildLlvmTools.clangWithLibcAndBasicRt
              else
                overrideCC stdenv buildLlvmTools.clangWithLibcAndBasicRt;
          }
          // lib.optionalAttrs (lib.versionOlder metadata.release_version "14") {
            # TODO: remove this, causes LLVM 13 packages rebuild.
            inherit (metadata) monorepoSrc; # Preserve bug during #307211 refactor.
          }
        );
      }
    )
  );

  noExtend = extensible: lib.attrsets.removeAttrs extensible [ "extend" ];
in
{
  inherit tools libraries;
  inherit (metadata) release_version;
}
// (noExtend libraries)
// (noExtend tools)
