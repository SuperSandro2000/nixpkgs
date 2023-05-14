{ lib
, fetchFromGitHub
, python3
, mopidy
}:

python3.pkgs.buildPythonApplication rec {
  pname = "mopidy-youtube";
  version = "unstable-2023-05-08";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "natumbri";
    repo = pname;
    rev = "baf841850fe083214ba92c760bd45adfe2774666";
    hash = "sha256-Kz8GykFfegTTCe/XXd+oixc7T3b8pss53dtoAIOOE+I=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    beautifulsoup4
    cachetools
    pykka
    requests
    youtube-dl
    ytmusicapi
  ] ++ [
    mopidy
  ];

  nativeCheckInputs = with python3.pkgs; [
    vcrpy
    pytestCheckHook
  ];

  disabledTests = [
    # Test requires a YouTube API key
    "test_get_default_config"
  ];

  disabledTestPaths = [
    # Disable tests which interact with Youtube
    "tests/test_api.py"
    "tests/test_backend.py"
    "tests/test_youtube.py"
  ];

  pythonImportsCheck = [
    "mopidy_youtube"
  ];

  meta = with lib; {
    description = "Mopidy extension for playing music from YouTube";
    homepage = "https://github.com/natumbri/mopidy-youtube";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
