{ lib
, buildPythonPackage
, fastnumbers
, fetchPypi
, glibcLocales
, hypothesis
, pyicu
, pytest-mock
, pytestCheckHook
, pythonOlder
}:

buildPythonPackage rec {
  pname = "natsort";
  version = "8.3.1";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UXWVSS3eVwpP1ranb2REQMG6UeIzjIpnHX8Edf2o+f0=";
  };

  propagatedBuildInputs = [
    fastnumbers
    pyicu
  ];

  nativeCheckInputs = [
    glibcLocales
    hypothesis
    pytest-mock
    pytestCheckHook
  ];

  disabledTests = [
    # timing sensitive test
    # hypothesis.errors.DeadlineExceeded: Test took 524.23ms, which exceeds the deadline of 200.00ms
    "test_string_component_transform_factory"
  ];

  pythonImportsCheck = [
    "natsort"
  ];

  meta = with lib; {
    description = "Natural sorting for Python";
    homepage = "https://github.com/SethMMorton/natsort";
    changelog = "https://github.com/SethMMorton/natsort/blob/${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
