{
  lib,
  buildPythonPackage,
  fetchPypi,
  music-assistant,
  setuptools,
}:

buildPythonPackage rec {
  pname = "music-assistant-frontend";
  version = "2.17.175";
  pyproject = true;

  src = fetchPypi {
    pname = "music_assistant_frontend";
    inherit version;
    hash = "sha256-LXrcfaWP9M+QPOPDIse3FDhe5h0+PUD0ieliD1ggMjk=";
  };

  build-system = [ setuptools ];

  doCheck = false;

  pythonImportsCheck = [ "music_assistant_frontend" ];

  meta = {
    changelog = "https://github.com/music-assistant/frontend/releases/tag/${version}";
    description = "Music Assistant frontend";
    homepage = "https://github.com/music-assistant/frontend";
    license = lib.licenses.asl20;
    inherit (music-assistant.meta) maintainers;
  };
}
