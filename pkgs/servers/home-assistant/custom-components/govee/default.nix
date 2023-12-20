{ lib
, buildHomeAssistantComponent
, fetchFromGitHub
, dacite
, govee-api-laggat
}:

buildHomeAssistantComponent rec {
  owner = "LaggAt";
  domain = "govee";
  version = "2023.11.1";

  src = fetchFromGitHub {
    owner = "LaggAt";
    repo = "hacs-govee";
    rev = version;
    hash = "sha256-NmIaqnbuKdj8CpxHY561TCTxAJcd8t3G+W9dH0FaEvY=";
  };

  dontBuild = true;

  propagatedBuildInputs = [
    dacite
    govee-api-laggat
  ];

  # has no tests
  doCheck = false;

  meta = with lib; {
    description = "The Govee integration allows you to control and monitor lights and switches using the Govee API";
    homepage = "https://github.com/LaggAt/hacs-govee";
    maintainers = with maintainers; [ SuperSandro2000 ];
    license = licenses.mit;
  };
}
