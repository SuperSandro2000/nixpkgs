{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "Franz646";
  domain = "orphan_cleaner";
  version = "4.2.1";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "orphan-cleaner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SHUIfLd3L/Q7sjxu+BoU6OGCG9k/ywOTJDM74+vybWs=";
  };

  meta = {
    changelog = "https://github.com/Franz646/orphan-cleaner/releases/tag/${finalAttrs.src.tag}";
    description = "Home Assistant integration to find and delete orphan entities";
    homepage = "https://github.com/Franz646/orphan-cleaner";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
