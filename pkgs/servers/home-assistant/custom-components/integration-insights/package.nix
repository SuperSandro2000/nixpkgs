{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "RaHehl";
  domain = "integration_insights";
  version = "0.2.1";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "integration-insights";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I4hoVjrLv6alOP8KsUdb83yigd6x2Y7KLzh7v9cQDtc=";
  };

  meta = {
    changelog = "https://github.com/RaHehl/integration-insights/releases/tag/${finalAttrs.src.tag}";
    description = "Finds Home Assistant integrations that slow down the event loop or use excessive CPU or memory";
    homepage = "https://github.com/RaHehl/integration-insights";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
