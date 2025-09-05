{
  lib,
  callPackage,
  buildPackages,
  targetPackages,
  opencl-clang,
  recurseIntoAttrs,
  patchesFn ? lib.id,
  # Allows passthrough to packages via newScope in ./common/default.nix.
  # This makes it possible to do
  # `(llvmPackages.override { <someLlvmDependency> = bar; }).clang` and get
  # an llvmPackages whose packages are overridden in an internally consistent way.
  ...
}:
let
  versions = {
    "15.0.7".sha256 = "sha256-wjuZQyXQ/jsmvy6y1aksCcEDXGBjuhpgngF3XQJ/T4s=";
  };

  mkPackage =
    {
      sha256,
      gitRelease ? null,
      monorepoSrc ? null,
      version ? null,
    }:
    let
      attrName = lib.versions.major version;
    in
    lib.nameValuePair attrName (
      recurseIntoAttrs (
        callPackage ./common-default.nix {
          buildLlvmTools = buildPackages.opencl-clang.llvmPkgs.tools;
          targetLlvmLibraries = targetPackages.opencl-clang.llvmPkgs.libraries or llvmPkgs.libraries;
          targetLlvm = targetPackages.opencl-clang.llvmPkgs.llvm or llvmPkgs.llvm;
          inherit
            sha256
            gitRelease
            monorepoSrc
            version
            patchesFn
            ;
        }
      )
    );

  llvmPkgs = lib.mapAttrs' (version: args: mkPackage (args // { inherit version; })) versions;
in
llvmPkgs // { inherit mkPackage versions; }
