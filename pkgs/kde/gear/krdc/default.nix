{
  lib,
  mkKdeDerivation,
  pkg-config,
  shared-mime-info,
  qtwayland,
  libssh,
  libvncserver,
  freerdp3,
}:
mkKdeDerivation {
  pname = "krdc";

  # freerdp3 is not yet supported by 24.12 version of krdc
  # can be dropped with 25.04 kdePackages release, as that will default to freerdp3
  # backporting freerdp3 support is non-trivial
  cmakeFlags = [
    (lib.cmakeBool "WITH_RDP" false)
  ];

  extraNativeBuildInputs = [
    pkg-config
    shared-mime-info
  ];

  extraCmakeFlags = [
    "-DWITH_RDP=OFF"
    "-DWITH_RDP3=ON"
  ];

  extraBuildInputs = [
    qtwayland
    libssh
    libvncserver
    freerdp3
  ];

  meta.mainProgram = "krdc";
}
