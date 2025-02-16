{
  lib,
  fetchFromGitHub,
  python3,
  nginx,
}:

let
  python = python3.override {
    self = python;
    packageOverrides = self: super: {
      pyparsing = super.pyparsing.overridePythonAttrs rec {
        version = "2.4.7";
        src = fetchFromGitHub {
          owner = "pyparsing";
          repo = "pyparsing";
          rev = "pyparsing_${version}";
          sha256 = "14pfy80q2flgzjcx8jkracvnxxnr59kjzp3kdm5nh232gk1v6g6h";
        };
        nativeBuildInputs = [ super.setuptools ];
      };
    };
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "gixy";
  version = "0.2.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dvershinin";
    repo = "gixy";
    tag = "v${version}";
    hash = "sha256-qGOvdmH4ZTk1v1ItHY9HaAgZtodmNgbUvJDa4JHfNzY=";
  };

  patches = [
    ./python3.13-compat.patch
  ];

  build-system = [ python.pkgs.setuptools ];

  dependencies = with python.pkgs; [
    configargparse
    pyparsing
    jinja2
    six
  ];

  nativeCheckInputs = with python.pkgs; [
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
    homepage = "https://github.com/yandex/gixy";
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.SuperSandro2000 ];
    platforms = lib.platforms.unix;
  };
}
