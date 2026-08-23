{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  aiohttp,
}:

buildHomeAssistantComponent rec {
  owner = "sfortis";
  domain = "openai_tts";
  version = "3.8";

  src = fetchFromGitHub {
    inherit owner;
    repo = "openai_tts";
    tag = "v${version}";
    hash = "sha256-z7uRTl+j5ySBXYCugBVPLkcvn+jPrB6s8ZrVurFIPCk=";
  };

  dependencies = [ aiohttp ];

  # has no tests
  doCheck = false;

  meta = {
    description = "Custom TTS component for Home Assistant. Utilizes the OpenAI speech engine or any compatible endpoint to deliver high-quality speech";
    homepage = "https://github.com/sfortis/openai_tts";
    changelog = "https://github.com/sfortis/openai_tts/releases/tag/${src.tag}";
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    license = lib.licenses.gpl3Only;
  };
}
