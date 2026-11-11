{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  jevclient,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "AboveColin";
  domain = "jev";
  version = "1.22.3";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "HA-Jev";
    tag = finalAttrs.version;
    hash = "sha256-NN6UmYc8uryacNEg0qJiHpjt5FOoiw0TU7skbN7GXS0=";
  };

  dependencies = [ jevclient ];

  meta = {
    description = "Home Assistant integration for asking Jev typed questions about home state";
    homepage = "https://github.com/AboveColin/HA-Jev";
    changelog = "https://github.com/AboveColin/HA-Jev/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
