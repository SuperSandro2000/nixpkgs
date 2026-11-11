{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  jevclient,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "AboveColin";
  domain = "jev";
  version = "1.23.0";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "HA-Jev";
    tag = finalAttrs.version;
    hash = "sha256-vcPySCxOY6Ys3S9XaaA5t1yubiXN4uyqJbposbwfAFE=";
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
