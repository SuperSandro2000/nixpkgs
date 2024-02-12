{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent rec {
  owner = "nielsfaber";
  domain = "scheduler";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "nielsfaber";
    repo = "scheduler-component";
    rev = "refs/tags/v${version}";
    hash = "sha256-bLZl4qeH96rVs8zPBHy3iSAn8DmJuefj4ZwO5lEtx1U=";
  };

  dontBuild = true;

  # has no tests
  doCheck = false;

  meta = with lib; {
    description = "Custom component for HA that enables the creation of scheduler entities";
    homepage = "https://github.com/nielsfaber/scheduler-component";
    changelog = "https://github.com/nielsfaber/scheduler-component/releases/tag/v${version}";
    maintainers = with maintainers; [ SuperSandro2000 ];
    license = licenses.gpl3;
  };
}
