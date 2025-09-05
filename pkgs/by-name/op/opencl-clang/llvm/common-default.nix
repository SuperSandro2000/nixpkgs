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

let
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
    getVersionFile =
      p:
      builtins.path {
        name = builtins.baseNameOf p;
        path =
          let
            patchDir = toString { path = metadata.versionDir; }.path;
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
        + ''
          ln -s "${lib.getLib cc}/lib/clang/${clangVersion}/include" "$rsrc"
        '';
      mkExtraBuildCommands =
        cc:
        mkExtraBuildCommands0 cc
        + ''
          ln -s "${targetLlvmLibraries.compiler-rt.out}/lib" "$rsrc/lib"
          ln -s "${targetLlvmLibraries.compiler-rt.out}/share" "$rsrc/share"
        '';
    in
    {
      compiler-rt = libraries.compiler-rt-libc;

      libllvm = callPackage ./llvm {
        inherit (buildPackages.opencl-clang.llvmPkgs) tblgen;
      };

      tblgen = callPackage ./tblgen.nix {
        patches =
          builtins.filter
            # Crude method to drop polly patches if present, they're not needed for tblgen.
            (p: (!lib.hasInfix "-polly" p))
            tools.libllvm.patches;
        clangPatches =
          # Would take tools.libclang.patches, but this introduces a cycle due
          # to replacements depending on the llvm outpath (e.g. the LLVMgold patch).
          # So take the only patch known to be necessary.
          ./clang/gnu-install-dirs.patch;
      };

      libclang = callPackage ./clang {
        inherit (buildPackages.opencl-clang.llvmPkgs) tblgen;
      };

      clang-unwrapped = tools.libclang;

      # pick clang appropriate for package set we are targeting
      clang = tools.libstdcxxClang;

      libstdcxxClang = wrapCCWith rec {
        cc = tools.clang-unwrapped;
        # libstdcxx is taken from gcc in an ad-hoc way in cc-wrapper.
        libcxx = null;
        extraPackages = [ targetLlvmLibraries.compiler-rt ];
        extraBuildCommands = mkExtraBuildCommands cc;
      };
    }
  );

  libraries = lib.makeExtensible (
    libraries:
    let
      callPackage = newScope (libraries // buildLlvmTools // args // metadata);
    in
    {
      compiler-rt-libc = callPackage ./compiler-rt (
        let
          # temp rename to avoid infinite recursion
          stdenv = args.stdenv;
        in
        {
          inherit stdenv;
        }
        // lib.optionalAttrs (stdenv.hostPlatform.useLLVM or false) {
          libxcrypt = (libxcrypt.override { inherit stdenv; }).overrideAttrs (old: {
            configureFlags = old.configureFlags ++ [ "--disable-symvers" ];
          });
        }
      );

      compiler-rt = libraries.compiler-rt-libc;
    }
  );

  noExtend = extensible: lib.attrsets.removeAttrs extensible [ "extend" ];
in
{
  inherit tools libraries;
  inherit (metadata) release_version;
}
// (noExtend libraries)
// (noExtend tools)
