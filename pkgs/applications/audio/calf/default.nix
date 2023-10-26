{ lib, stdenv, fetchurl, expat, fftwSinglePrec, fluidsynth, glib
, libjack2, ladspaH , lv2, pkg-config }:

stdenv.mkDerivation rec {
  pname = "calf";
  version = "0.90.3";

  src = fetchurl {
    url = "https://calf-studio-gear.org/files/${pname}-${version}.tar.gz";
    sha256 = "17x4hylgq4dn9qycsdacfxy64f5cv57n2qgkvsdp524gnqzw4az3";
  };

  outputs = [ "out" "doc" ];

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    expat fftwSinglePrec fluidsynth glib libjack2 ladspaH
    lv2
  ];

  configureFlags = [ "--without-gui" ];

  meta = with lib; {
    homepage = "https://calf-studio-gear.org";
    description = "A set of high quality open source audio plugins for musicians";
    license = licenses.lgpl2;
    maintainers = [ maintainers.goibhniu ];
    platforms = platforms.linux;
    mainProgram = "calfjackhost";
  };
}
