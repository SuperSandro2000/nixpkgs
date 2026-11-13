{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  pytest-asyncio,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "Vituhlos";
  domain = "ikea_bilresa";
  version = "0.6.1";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "ha-ikea-bilresa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NEZrbT4AJQnp3QD/nYor0YA+hE8CdIUu+VKxXExTbzQ=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  meta = {
    description = "Home Assistant integration for smooth IKEA BILRESA scroll wheel dimming over Matter";
    homepage = "https://github.com/Vituhlos/ha-ikea-bilresa";
    changelog = "https://github.com/Vituhlos/ha-ikea-bilresa/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
