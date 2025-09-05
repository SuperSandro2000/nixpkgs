{
  lib,
  fetchFromGitHub ? null,
  release_version ? null,
  officialRelease ? null,
  # monorepoSrc' ? null,
  version ? null,
}@args:

rec {
  llvm_meta = {
    license = [ lib.licenses.ncsa ];
    teams = [ lib.teams.llvm ];

    # See llvm/cmake/config-ix.cmake.
    platforms = lib.platforms.x86;
  };

  releaseInfo = rec {
      original = officialRelease;
      release_version = args.version;
      version = release_version;
    };

  monorepoSrc = fetchFromGitHub rec {
    owner = "llvm";
    repo = "llvm-project";
    rev = "llvmorg-${releaseInfo.version}";
    sha256 = releaseInfo.original.sha256;
    passthru = { inherit owner repo rev; };
  };
}
