{ lib, fetchFromGitHub, python3 }:

let
  python = python3.override {
    packageOverrides = self: super: {
      pyparsing = super.pyparsing.overridePythonAttrs (oldAttrs: rec {
        version = "2.4.7";
        src = fetchFromGitHub {
          owner = "pyparsing";
          repo = "pyparsing";
          rev = "pyparsing_${version}";
          sha256 = "14pfy80q2flgzjcx8jkracvnxxnr59kjzp3kdm5nh232gk1v6g6h";
        };
        nativeBuildInputs = [
          super.setuptools
        ];
      });
    };
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "gixy";
  version = "0.1.22";

  src = fetchFromGitHub {
    owner = "dvershinin";
    repo = "gixy";
    rev = "v${version}";
    hash = "sha256-Eb89rbfwOTsP6I9UXuB3+PrKh3efIOwGCnbsBH1rR3o=";
  };

  postPatch = ''
    sed -ie '/argparse/d' setup.py
  '';

  propagatedBuildInputs = with python.pkgs; [
    cached-property
    configargparse
    pyparsing
    jinja2
    nose
    setuptools
    six
  ];

  meta = with lib; {
    description = "Nginx configuration static analyzer";
    longDescription = ''
      Gixy is a tool to analyze Nginx configuration.
      The main goal of Gixy is to prevent security misconfiguration and automate flaw detection.
    '';
    homepage = "https://github.com/yandex/gixy";
    license = licenses.mpl20;
    maintainers = [ maintainers.willibutz ];
    platforms = platforms.unix;
  };
}
