{
  lib,
  babel,
  buildHomeAssistantComponent,
  defusedxml,
  epaper-dithering,
  fetchFromGitHub,
  fetchPnpmDeps,
  home-assistant,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  pytest-homeassistant,
  pytestCheckHook,
  resvg-py,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "cryptomilk";
  domain = "eink_dashboard";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "cryptomilk";
    repo = "hass-eink-dashboard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q2kwlM6FZATgqAkkdcoDGvYg4xMuHW4INP2CGMuoiZI=";
  };

  pnpmRoot = "custom_components/eink_dashboard/frontend";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    sourceRoot = "${finalAttrs.src.name}/${finalAttrs.pnpmRoot}";
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-lFXzitYX/gqP1lTh5/t6YTHkjM/ZoeqBC2Hsnh36ixI=";
  };

  postPatch = ''
    for file in tests/*.py; do
      sed -i 's/pytest_homeassistant_custom_component/pytest_homeassistant/g' "$file"
    done
  '';

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
    home-assistant
    pytest-homeassistant
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
