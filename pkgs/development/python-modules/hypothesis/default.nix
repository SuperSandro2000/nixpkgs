{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, attrs
, exceptiongroup
, pexpect
, doCheck ? true
, pytestCheckHook
, pytest-xdist
, sortedcontainers
, pythonOlder
}:

buildPythonPackage rec {
  pname = "hypothesis";
  version = "6.54.5";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "HypothesisWorks";
    repo = "hypothesis";
    rev = "hypothesis-python-${version}";
    hash = "sha256-mr8ctmAzRgWNVpW+PZlOhaQ0l28P0U8PxvjoVjfHX78=";
  };

  postUnpack = "sourceRoot=$sourceRoot/hypothesis-python";

  propagatedBuildInputs = [
    attrs
    sortedcontainers
  ] ++ lib.optionals (pythonOlder "3.11") [
    exceptiongroup
  ];

  checkInputs = [
    pexpect
    pytest-xdist
    pytestCheckHook
  ];

  inherit doCheck;

  # This file changes how pytest runs and breaks it
  preCheck = ''
    rm tox.ini
  '';

  pytestFlagsArray = [
    "tests/cover"
  ];

  # tests crash
  # :-1: running the test CRASHED with signal 0
  # https://hydra.hq.c3d2.de/build/62701/nixlog/1
  disabledTests = lib.optionals stdenv.isAarch64 [
    "test_cache_is_threadsafe_issue_2433_regression"
    "test_can_run_with_database_in_thread"
  ];

  pythonImportsCheck = [
    "hypothesis"
  ];

  meta = with lib; {
    description = "Library for property based testing";
    homepage = "https://github.com/HypothesisWorks/hypothesis";
    license = licenses.mpl20;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
