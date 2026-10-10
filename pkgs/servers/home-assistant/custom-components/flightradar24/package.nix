{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  fetchpatch,
  flightradarapi,
  pycountry,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "AlexandrErohin";
  domain = "flightradar24";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "AlexandrErohin";
    repo = "home-assistant-flightradar24";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PosY4XkONbQk+9w20TbbNT2q+JuoG0vacbsZ8HfRdg4=";
  };

  patches = [
    # Retry setup when the FR24 login is rate limited
    (fetchpatch {
      url = "https://github.com/AlexandrErohin/home-assistant-flightradar24/pull/328.patch";
      hash = "sha256-ocJFJl2MffObYO2l5K5AhxV1aPMDxEP+emblMH8/mz4=";
    })
    # Stop hammering a rate limited endpoint, and keep the expected 429 out of the error log
    (fetchpatch {
      url = "https://github.com/AlexandrErohin/home-assistant-flightradar24/pull/333.diff";
      hash = "sha256-LLQcWxNLXGPJ8iWkpwSjvnWK/+6kOZmwnwIq+ZylF1M=";
    })
  ];

  ignoreVersionRequirement = [
    "FlightRadarAPI"
    "pycountry"
  ];

  dependencies = [
    flightradarapi
    pycountry
  ];

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  meta = {
    description = "Flightradar24 integration for Home Assistant";
    homepage = "https://github.com/AlexandrErohin/home-assistant-flightradar24";
    changelog = "https://github.com/AlexandrErohin/home-assistant-flightradar24/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
