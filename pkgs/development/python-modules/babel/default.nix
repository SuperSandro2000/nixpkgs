{ stdenv, lib, buildPythonPackage, fetchPypi, pytz, pytestCheckHook, freezegun }:

buildPythonPackage rec {
  pname = "babel";
  version = "2.11.0";

  src = fetchPypi {
    pname = "Babel";
    inherit version;
    sha256 = "sha256-XvSzImsBgN7d7UIpZRyLDho6aig31FoHMnLzE+TPl/Y=";
  };

  propagatedBuildInputs = [ pytz ];

  checkInputs = [ pytestCheckHook freezegun ];

  doCheck = !stdenv.isDarwin;

  meta = with lib; {
    homepage = "https://babel.pocoo.org/";
    description = "Collection of internationalizing tools";
    license = licenses.bsd3;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
