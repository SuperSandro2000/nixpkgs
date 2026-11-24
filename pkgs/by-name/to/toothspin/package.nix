{
  lib,
  fetchFromGitHub,
  python3Packages,
  ...
}:

python3Packages.buildPythonApplication rec {
  pname = "toothspin";
  version = "0.6.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "eknoes";
    repo = "toothspin";
    tag = "v${version}";
    hash = "sha256-bXWldlHU7ccR2MNP0ziFsfNpuuCWCre5hkAGSf+ZmzU=";
  };

  pythonRelaxDeps = [ "aiosendspin" ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    aiosendspin
    dbus-fast
  ];

  nativeCheckInputs =
    with python3Packages;
    [
      pytest-timeout
      pytestCheckHook
    ]
    ++ aiosendspin.optional-dependencies.server;

  pythonImportsCheck = [ "toothspin" ];

  disabledTestPaths = [
    # no mDNS in the sandbox
    "tests/test_server.py"
  ];

  meta = {
    description = "Bluetooth audio input for Sendspin and Music Assistant";
    homepage = "https://github.com/eknoes/toothspin";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.SuperSandro2000 ];
    mainProgram = "toothspin";
    platforms = lib.platforms.linux;
  };
}
