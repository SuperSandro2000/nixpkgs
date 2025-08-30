{
  lib,
  build,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  hatch-vcs,
  jsonschema,
  magicgui,
  napari, # reverse dependency, for tests
  napari-plugin-engine,
  numpy,
  platformdirs,
  psygnal,
  pydantic,
  pytestCheckHook,
  pythonOlder,
  pyyaml,
  rich,
  typer,
  tomli-w,
}:

buildPythonPackage rec {
  pname = "napari-npe2";
  version = "0.7.9";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "napari";
    repo = "npe2";
    tag = "v${version}";
    hash = "sha256-q+vgzUuSSHFR64OajT/j/tLsNgSm3azQPCvDlrIvceM=";
  };

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    build
    pydantic
    pyyaml
    platformdirs
    psygnal
    rich
    typer
    tomli-w
  ];

  nativeBuildInputs = [
    jsonschema
    magicgui
    napari-plugin-engine
    numpy
    pytestCheckHook
  ];

  disabledTestPaths = [
    # requires internet
    "tests/test_fetch.py"
    # requires unpackaged pytest-pretty
    "tests/test_pytest_plugin.py"
  ];

  disabledTests = [
    # requires internet
    "test_cli_fetch"
    # requires an old version of napari-svg
    "test_cli_convert_svg"
    "test_conversion"
  ];

  pythonImportsCheck = [ "npe2" ];

  passthru.tests = {
    inherit napari;
  };

  meta = with lib; {
    description = "Plugin system for napari (the image visualizer)";
    homepage = "https://github.com/napari/npe2";
    license = licenses.bsd3;
    maintainers = with maintainers; [ SomeoneSerge ];
    mainProgram = "npe2";
  };
}
