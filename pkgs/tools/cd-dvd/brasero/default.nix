{
  stdenv,
  lib,
  fetchurl,
  pkg-config,
  gtk3,
  itstool,
  gst_all_1,
  libxml2,
  libnotify,
  libcanberra-gtk3,
  intltool,
  dvdauthor,
  libburn,
  libisofs,
  vcdimager,
  wrapGAppsHook3,
  hicolor-icon-theme,
}:

let
  major = "3.12";
  minor = "3";
  binpath = lib.makeBinPath [
    dvdauthor
    vcdimager
  ];

in
stdenv.mkDerivation rec {
  version = "${major}.${minor}";
  pname = "brasero";

  src = fetchurl {
    url = "mirror://gnome/sources/brasero/${major}/${pname}-${version}.tar.xz";
    hash = "sha256-h3SerjOhQSB9GwC+IzttgEWYLtMkntS5ja4fOpdf6hU=";
  };

  nativeBuildInputs = [
    pkg-config
    itstool
    intltool
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libxml2
    libnotify
    libcanberra-gtk3
    libburn
    libisofs
    hicolor-icon-theme
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  # brasero checks that the applications it uses aren't symlinks, but this
  # will obviously not work on nix
  patches = [ ./remove-symlink-check.patch ];

  enableParallelBuilding = true;

  configureFlags = [
    "--with-girdir=$out/share/gir-1.0"
    "--with-typelibdir=$out/lib/girepository-1.0"
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : "${binpath}")
  '';

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  };

  meta = with lib; {
    description = "Gnome CD/DVD Burner";
    homepage = "https://gitlab.gnome.org/GNOME/brasero";
    maintainers = [ maintainers.bdimcheff ];
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    mainProgram = "brasero";
  };
}
