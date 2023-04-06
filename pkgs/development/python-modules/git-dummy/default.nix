{ lib
, buildPythonPackage
, fetchFromGitHub
, gitpython
, typer
, pydantic
}:

buildPythonPackage rec {
  pname = "git-dummy";
  version = "0.0.7";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "initialcommit-com";
    repo = "git-dummy";
    rev = "v${version}";
    hash = "sha256-Q8bo5zWVRsuH0Y8dc4WM85E8SGYOzdfhbzLJ1u23YIU=";
  };

  propagatedBuildInputs = [
    gitpython
    typer
    pydantic
  ];

  # Tests are currently broken
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/initialcommit-com/git-dummy";
    description = "Generate dummy Git repositories populated with the desired number of commits, branches, and structure.";
    license = licenses.gpl2;
    maintainers = with maintainers; [ mathiassven ];
  };
}
