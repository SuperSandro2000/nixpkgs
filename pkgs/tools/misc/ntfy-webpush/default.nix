{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "ntfy-webpush";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "dschep";
    repo = "ntfy-webpush";
    rev = "v${version}";
    sha256 = "1dxlvq3glf8yjkn1hdk89rx1s4fi9ygg46yn866a9v7a5a83zx2n";
  };

  postPatch = ''
    sed -i "s|'ntfy', ||" setup.py
  '';

  propagatedBuildInputs = with python3Packages; [
    pywebpush
    py-vapid
  ];

  meta = with lib; {
    description = "cloudbell webpush notification support for ntfy";
    homepage = "https://dschep.github.io/ntfy-webpush/";
    license = licenses.mit;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
