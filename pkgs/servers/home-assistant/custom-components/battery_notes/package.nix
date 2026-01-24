{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent rec {
  owner = "andrew-codechimp";
  domain = "battery_notes";
  version = "3.2.5";

  src = fetchFromGitHub {
    owner = "andrew-codechimp";
    repo = "HA-Battery-Notes";
    tag = version;
    hash = "sha256-MxJeE4wPA31ME9Or8XTW5+owISSep9MOt57LHb131ec=";
  };

  # has no tests
  doCheck = false;

  meta = {
    description = "Home Assistant integration to provide battery details of devices";
    homepage = "https://github.com/andrew-codechimp/HA-Battery-Notes";
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    license = lib.licenses.mit;
  };
}
