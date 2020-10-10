{ stdenv, fetchurl, makeWrapper, php }:

stdenv.mkDerivation rec {
  pname = "serenata";
  version = "5.4.0";

  src = fetchurl {
    url = "https://gitlab.com/Serenata/Serenata/-/jobs/735379568/artifacts/raw/bin/distribution.phar";
    sha256 = "05xjgyas5vrr7prbg575drqgw1dpc1aiff9iqya15zn6ccnrx4bx";
  };

  dontUnpack = true; 

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -m0755 -D $src $out/bin/serenata
    wrapProgram $out/bin/serenata --prefix PATH ":" "${stdenv.lib.makeBinPath [ php ]}";
  '';

  meta = with stdenv.lib; {
    description = "Gratis, libre and open source server providing code assistance for PHP";
    homepage = "https://serenata.gitlab.io/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
