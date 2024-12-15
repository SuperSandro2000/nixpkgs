{
  mkKdeDerivation,
  pkg-config,
  qtbase,
  libvncserver,
  pipewire,
  xorg,
}:
mkKdeDerivation {
  pname = "krfb";

  extraCmakeFlags = [
    "-DQtWaylandScanner_EXECUTABLE=${qtbase}/libexec/qtwaylandscanner"
  ];

  extraNativeBuildInputs = [ pkg-config ];
  extraBuildInputs = [
    libvncserver
    pipewire
    xorg.libXdamage
  ];

  postInstall = ''
    ln -s $out/share/krfb/krfb.notifyrc $out/share/krfb.notifyrc
    ln -s $out/share/krfb/krfb.notifyrc $out/share/krfb-virtualmonitor.notifyrc
  '';
}
