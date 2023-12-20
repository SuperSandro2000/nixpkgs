{ lib
, buildPythonPackage
, fetchFromGitHub
, aiohttp
, bios
, certifi
, dacite
, events
, pexpect
, pygatt
, pytest-asyncio
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "govee-api-laggat";
  version = "0.2.2";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "LaggAt";
    repo = "python-govee-api";
    rev = version;
    hash = "sha256-0vo8/bQftEk+K0+4Wd427tcOPC18racaOnM4ztT7yCc=";
  };

  propagatedBuildInputs = [
    aiohttp
    bios
    certifi
    dacite
    events
    pexpect
    pygatt
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  pythonImportsCheck = [
    "govee_api_laggat"
  ];

  meta = with lib; {
    description = "Control Govee Lights from Python";
    homepage = "https://github.com/LaggAt/python-govee-api";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
