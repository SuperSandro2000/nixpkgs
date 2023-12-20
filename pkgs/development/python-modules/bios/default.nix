{ lib
, buildPythonPackage
, fetchPypi
, oyaml
, pyyaml
}:

buildPythonPackage rec {
  pname = "bios";
  version = "0.1.2";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-vM/CQBG2pjGm7e7xBpVRpOyq/3s+1QpiIaaAdYUFAOk=";
  };

  propagatedBuildInputs = [
    oyaml
    pyyaml
  ];

  # has no tests
  doCheck = false;

  pythonImportsCheck = [
    "bios"
  ];

  meta = with lib; {
    description = "Library which helps you to read and write data to determined type of files";
    homepage = "https://github.com/bilgehannal/bios";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
