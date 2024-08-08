{ lib
, stdenv
, fetchFromGitHub
, eglexternalplatform
, pkg-config
, meson
, ninja
, wayland-scanner
, libGL
, libX11
, libdrm
, wayland
, wayland-protocols
}:

stdenv.mkDerivation rec {
  pname = "egl-wayland";
  version = "1.1.14-unstable-2024-08-06";

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "Nvidia";
    repo = pname;
    # fix for firefox 128
    # https://github.com/NVIDIA/egl-wayland/pull/124
    rev = "bd426eb032caf73e654f51234d62c8c8dd7a76e5";
    hash = "sha256-YLQc5+IeSNr6FRm8VVcarF7o/qxICrjazkS2eefV33o=";
  };

  postPatch = ''
    # Declares an includedir but doesn't install any headers
    # CMake's `pkg_check_modules(NAME wayland-eglstream IMPORTED_TARGET)` considers this an error
    sed -i -e '/includedir/d' wayland-eglstream.pc.in
  '';

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libGL
    libX11
    libdrm
    wayland
    wayland-protocols
  ];

  propagatedBuildInputs = [
    eglexternalplatform
  ];

  meta = with lib; {
    description = "EGLStream-based Wayland external platform";
    homepage = "https://github.com/NVIDIA/egl-wayland/";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ hedning ];
  };
}
