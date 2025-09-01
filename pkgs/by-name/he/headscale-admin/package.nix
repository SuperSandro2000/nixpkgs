{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  fetchNpmDeps,
  endpoint ? "/admin",
}:

buildNpmPackage (finalAttrs: {
  pname = "headscale-admin";
  version = "0.25.6";

  src = fetchFromGitHub {
    owner = "GoodiesHQ";
    repo = "headscale-admin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qAihn3RUSUbl/NfN0sISKHJvyD7zj0E+VDVtlEpw8y4=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-yu52aOSKXlRxM8jmADiiBkr/NI5c1zFFOdBHoJHWd2c=";
  };

  buildPhase = ''
    runHook preBuild

    export ENDPOINT="${endpoint}"
    npm run build | cat

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r build/ $out/${endpoint}/

    runHook postInstall
  '';

  meta = {
    description = " Admin Web Interface for headscale";
    homepage = "https://github.com/GoodiesHQ/headscale-admin";
    changelog = "https://github.com/GoodiesHQ/headscale-admin/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
