{ lib
, applyPatches
, buildNpmPackage
, fetchFromGitHub
, fetchpatch
, git
, nixosTests
, python3
}:

let
  version = "2024.1.1";

  bw_web_builds = applyPatches {
    src = fetchFromGitHub {
      owner = "dani-garcia";
      repo = "bw_web_builds";
      rev = "v${version}";
      hash = "sha256-xtfpxcJLP0C4FdnO45gsaecOWJ/cKC++Abm7iatTH1Y=";
    };

    patches = [
      #  Fix applying latest patch if patches is a symlink
      # https://github.com/dani-garcia/bw_web_builds/pull/152
      (fetchpatch {
        url = "https://github.com/dani-garcia/bw_web_builds/commit/5367c2447d9e2ec1e8d8493dadd7eeb80bbd5bce.patch";
        hash = "sha256-z50w8xbQ98ZxBQWHUxK9KGLOjmgFsIsJoVnlA3rdwkw=";
      })
    ];
  };

in buildNpmPackage rec {
  pname = "vaultwarden-webvault";
  inherit version;

  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    rev = "web-v${lib.removeSuffix "b" version}";
    hash = "sha256-695iCkFhPEyyI4ekbjsdWpxgPy+bX392/X30HyL4F4Y=";
  };

  npmDepsHash = "sha256-IJ5JVz9hHu3NOzFJAyzfhsMfPQgYQGntDEDuBMI/iZc=";

  postPatch = ''
    ln -s ${bw_web_builds}/{patches,resources} ..
    PATH="${git}/bin:$PATH" VAULT_VERSION="${lib.removePrefix "web-" src.rev}" \
      bash ${bw_web_builds}/scripts/apply_patches.sh
  '';

  nativeBuildInputs = [
    python3
  ];

  makeCacheWritable = true;

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  npmBuildScript = "dist:oss:selfhost";

  npmBuildFlags = [
    "--workspace" "apps/web"
  ];

  npmFlags = [ "--legacy-peer-deps" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/vaultwarden
    mv apps/web/build $out/share/vaultwarden/vault
    runHook postInstall
  '';

  passthru = {
    inherit bw_web_builds;
    tests = nixosTests.vaultwarden;
  };

  meta = with lib; {
    description = "Integrates the web vault into vaultwarden";
    homepage = "https://github.com/dani-garcia/bw_web_builds";
    platforms = platforms.all;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ dotlambda msteen mic92 ];
  };
}
