{
  mkKdeDerivation,
  pkg-config,
  qtwayland,
  libvncserver,
  pipewire,
  xorg,
}:
mkKdeDerivation {
  pname = "krfb";

  extraCmakeFlags = [
    "-DQtWaylandScanner_EXECUTABLE=${qtwayland}/libexec/qtwaylandscanner"
  ];

  extraNativeBuildInputs = [ pkg-config ];
  extraBuildInputs = [
    qtwayland
    libvncserver
    pipewire
    xorg.libXdamage
  ];

  postInstall = ''
    ln -s $out/share/krfb/krfb.notifyrc $out/share/krfb.notifyrc
    ln -s $out/share/krfb/krfb.notifyrc $out/share/krfb-virtualmonitor.notifyrc
  '';
}
