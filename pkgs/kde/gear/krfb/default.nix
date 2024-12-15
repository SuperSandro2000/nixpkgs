{
  mkKdeDerivation,
  pkg-config,
  qtbase,
  libvncserver,
  pipewire,
  libxdamage,
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
    libxdamage
  ];

  postInstall = ''
    ln -s $out/share/krfb/krfb.notifyrc $out/share/krfb.notifyrc
    ln -s $out/share/krfb/krfb.notifyrc $out/share/krfb-virtualmonitor.notifyrc
  '';
}
