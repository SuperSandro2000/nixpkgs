{
  lib,
  fetchFromGitHub ? null,
  release_version ? null,
  gitRelease ? null,
  officialRelease ? null,
  monorepoSrc' ? null,
  version ? null,
}@args:

rec {
  llvm_meta = {
    license = [ lib.licenses.ncsa ];
    teams = [ lib.teams.llvm ];

    # See llvm/cmake/config-ix.cmake.
    platforms = lib.platforms.x86;
  };

  releaseInfo =
    if gitRelease != null then
      rec {
        original = gitRelease;
        release_version = args.version or original.version;
        version = gitRelease.rev-version;
      }
    else
      rec {
        original = officialRelease;
        release_version = args.version or original.version;
        version =
          if original ? candidate then "${release_version}-${original.candidate}" else release_version;
      };

  monorepoSrc =
    if monorepoSrc' != null then
      monorepoSrc'
    else
      let
        sha256 = releaseInfo.original.sha256;
        rev = if gitRelease != null then gitRelease.rev else "llvmorg-${releaseInfo.version}";
      in
      fetchFromGitHub rec {
        owner = "llvm";
        repo = "llvm-project";
        inherit rev sha256;
        passthru = { inherit owner repo rev; };
      };

}
