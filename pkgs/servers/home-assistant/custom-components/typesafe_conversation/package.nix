{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "the-sof";
  domain = "typesafe_conversation";
  version = "0.7.1";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "home-assistant-typesafe-conversation-agent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kzyYUvEk6UBoq4imWlmHQHtebTyOhSGHxfDzQ22nRmk=";
  };

  meta = {
    description = "Home Assistant conversation agent using TypeSafe's System One decision model";
    homepage = "https://github.com/the-sof/home-assistant-typesafe-conversation-agent";
    changelog = "https://github.com/the-sof/home-assistant-typesafe-conversation-agent/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
