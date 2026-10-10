{
  buildGoModule,
  lib,
  fetchFromGitHub,
  fetchpatch,
}:

buildGoModule (finalAttrs: {
  pname = "go-tools";
  version = "2026.2.1";

  src = fetchFromGitHub {
    owner = "dominikh";
    repo = "go-tools";
    tag = finalAttrs.version;
    sha256 = "sha256-wellofnfLW4lQy68UQyFJfvrKCfrZ/EllLODX1g9taY=";
  };

  patches = [
    # go 1.27.2 support
    (fetchpatch {
      url = "https://github.com/dominikh/go-tools/commit/f1838cc308e5cfbb38d91cfc973355611845997e.patch";
      hash = "sha256-ozZT78h2tH6N61eEL7SHd51vzpul2XwzIUcv1g8n1fM=";
    })
    (fetchpatch {
      url = "https://github.com/dominikh/go-tools/commit/1341da9da9eb3f2de42c4d7bc020a6a89a40da23.patch";
      hash = "sha256-msu/e7/TTMWWbMXqwsBiNsp4SYNcnJM641rfx+sUIdU=";
    })
  ];

  vendorHash = "sha256-hGhti2JALbY0cq8DgAC4/viY2K+uo7wexEMh4x6C5uQ=";

  excludedPackages = [ "website" ];

  meta = {
    description = "Collection of tools and libraries for working with Go code, including linters and static analysis";
    changelog = "https://github.com/dominikh/go-tools/releases/tag/${finalAttrs.src.tag}";
    homepage = "https://staticcheck.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      rvolosatovs
      kalbasit
      smasher164
    ];
  };
})
