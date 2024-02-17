{ lib
, buildHomeAssistantComponent
, fetchFromGitHub
, prettytable
}:

buildHomeAssistantComponent rec {
  owner = "Watchman";
  domain = "watchman";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "dummylabs";
    repo = "thewatchman";
    rev = "v${version}";
    hash = "sha256-YD38/rJ5mpvKjpxRjRDnsvqJPbASuLYQOH2FXZBb8w0=";
  };

  dontBuild = true;

  propagatedBuildInputs = [
    prettytable
  ];

  # enable when pytest-homeassistant-custom-component is packaged
  doCheck = false;

  # nativeCheckInputs = [
  #   pytest-homeassistant-custom-component
  #   pytestCheckHook
  # ];

  meta = with lib; {
    description = "Control Govee lights via the LAN API from Home Assistant";
    homepage = "https://github.com/wez/govee-lan-hass";
    maintainers = with maintainers; [ SuperSandro2000 ];
    license = licenses.mit;
  };
}
