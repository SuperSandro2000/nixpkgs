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
  version = "0.28.4";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "philips_sonicare_ble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mhSDzVnQiqUgRkOMt+UuvWzVT4JWrydDpyxuY/Qd1To=";
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
