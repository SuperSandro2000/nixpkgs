{
  lib,
  babel,
  buildHomeAssistantComponent,
  defusedxml,
  epaper-dithering,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
  resvg-py,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "cryptomilk";
  domain = "eink_dashboard";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "cryptomilk";
    repo = "hass-eink-dashboard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-s9tIuzE1hn9GmabPIUzAGZfaI92hob3a1I9Egp8rR1w=";
  };

  pnpmRoot = "custom_components/eink_dashboard/frontend";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmRoot
      ;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-lFXzitYX/gqP1lTh5/t6YTHkjM/ZoeqBC2Hsnh36ixI=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  preBuild = ''
    cd custom_components/eink_dashboard/frontend
    pnpm run build
    cd -
  '';

  dependencies = [
    babel
    defusedxml
    epaper-dithering
    resvg-py
  ];

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  # required for all tests to succeed
  preCheck = ''
    cd custom_components/eink_dashboard/frontend
    pnpm install --offline --frozen-lockfile
    cd -
  '';

  preInstall = ''
    rm -r custom_components/eink_dashboard/frontend/node_modules
  '';

  meta = {
    description = "Home Assistant custom component that renders e-ink dashboard images from entity state";
    homepage = "https://github.com/cryptomilk/hass-eink-dashboard";
    changelog = "https://github.com/cryptomilk/hass-eink-dashboard/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
