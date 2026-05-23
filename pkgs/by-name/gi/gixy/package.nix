{
  lib,
  fetchFromGitHub,
  python3Packages,
  nginx,
}:

python3Packages.buildPythonApplication rec {
  pname = "gixy";
  version = "0.3.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "MegaManSec";
    repo = "Gixy-Next";
    rev = "v${version}";
    hash = "sha256-i4LBhSd5HSqzvvYLgm7JVO4pnMRhsGmDKI2FItp/1mE=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    configargparse
    crossplane
    jinja2
    pyparsing
    tldextract
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-xdist
  ];

  passthru = {
    inherit (nginx.passthru) tests;
  };

  meta = {
    description = "Nginx configuration static analyzer";
    mainProgram = "gixy";
    longDescription = ''
      Gixy is a tool to analyze Nginx configuration.
      The main goal of Gixy is to prevent security misconfiguration and automate flaw detection.
    '';
    homepage = "https://github.com/MegaManSec/Gixy-Next";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.SuperSandro2000 ];
    platforms = lib.platforms.unix;
  };
}
