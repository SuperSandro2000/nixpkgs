{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "hiSweid";
  domain = "last_changed_keeper";
  version = "0.9.19";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "last_changed_keeper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PY0RPUYZUGNgLdhrnJCBAOCirekFqYbDvtNDIUirhfw=";
  };

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  meta = {
    changelog = "https://github.com/hiSweid/last_changed_keeper/releases/tag/${finalAttrs.src.tag}";
    description = "Keep the real last-changed time of entities after a Home Assistant restart";
    homepage = "https://github.com/hiSweid/last_changed_keeper";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
