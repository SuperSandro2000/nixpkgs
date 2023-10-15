{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, immer
, zug
}:

stdenv.mkDerivation rec {
  pname = "lager";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = "lager";
    rev = "v${version}";
    hash = "sha256-KTHrVV/186l4klwlcfDwFsKVoOVqWCUPzHnIbWuatbg=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    boost
    immer
    zug
  ];

  cmakeFlags = [
    "-Dlager_BUILD_EXAMPLES=OFF"
  ];

  meta = with lib; {
    homepage    = "https://github.com/arximboldi/lager";
    description = "library for functional interactive c++ programs";
    license     = licenses.lgpl3Plus;
    maintainers = with maintainers; [ nek0 ];
  };
}
