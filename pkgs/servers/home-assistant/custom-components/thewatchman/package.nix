{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  aiofiles,
  prettytable,
}:

buildHomeAssistantComponent rec {
  owner = "Watchman";
  domain = "watchman";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "dummylabs";
    repo = "thewatchman";
    rev = "v${version}";
    hash = "sha256-Ctvhmw9yMQn+wa3b4LSgHVxipEcalVyk4ovg+GINO38=";
  };

  dontBuild = true;

  propagatedBuildInputs = [
    aiofiles
    prettytable
  ];

  # enable when pytest-homeassistant-custom-component is packaged
  doCheck = false;

  # nativeCheckInputs = [
  #   pytest-homeassistant-custom-component
  #   pytestCheckHook
  # ];

  meta = with lib; {
    description = "Keep track of missing entities and services in your config files";
    homepage = "https://github.com/dummylabs/thewatchman";
    maintainers = with maintainers; [ SuperSandro2000 ];
    license = licenses.mit;
  };
}
