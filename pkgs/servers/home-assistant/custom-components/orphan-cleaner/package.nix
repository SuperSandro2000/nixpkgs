{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "Franz646";
  domain = "orphan_cleaner";
  version = "4.1.2";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "orphan-cleaner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A3UnHrQ/mUtvzi5DGCPxmFXGifQJcM9LCo6Kl6Iwj9g=";
  };

  meta = {
    changelog = "https://github.com/Franz646/orphan-cleaner/releases/tag/${finalAttrs.src.tag}";
    description = "Home Assistant integration to find and delete orphan entities";
    homepage = "https://github.com/Franz646/orphan-cleaner";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
