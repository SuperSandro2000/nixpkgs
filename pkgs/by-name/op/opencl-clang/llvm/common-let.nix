{
  lib,
  fetchFromGitHub ? null,
  sha256 ? null,
  version ? null,
}:

{
  llvm_meta = {
    license = [ lib.licenses.ncsa ];
    teams = [ lib.teams.llvm ];

    # See llvm/cmake/config-ix.cmake.
    platforms = lib.platforms.x86;
  };

  monorepoSrc = fetchFromGitHub rec {
    owner = "llvm";
    repo = "llvm-project";
    rev = "llvmorg-${version}";
    inherit sha256;
  };
}
