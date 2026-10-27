{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  homeassistant,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "mtheli";
  domain = "philips_sonicare_ble";
  version = "0.30.1";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "philips_sonicare_ble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ySZcKNm7y/ww9bE/b0HspXypiYf5IRpuQl3XRb+ZBTo=";
  };

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytestCheckHook
  ]
  ++ (homeassistant.getPackages "bluetooth" homeassistant.python3Packages);

  meta = {
    changelog = "https://github.com/mtheli/philips_sonicare_ble/releases/tag/${finalAttrs.src.tag}";
    description = "Philips Sonicare BLE integration for Home Assistant";
    homepage = "https://github.com/mtheli/philips_sonicare_ble";
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    license = lib.licenses.mit;
  };
})
