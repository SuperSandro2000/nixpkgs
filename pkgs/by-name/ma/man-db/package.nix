{
  buildPackages,
  gdbm,
  fetchurl,
  groff,
  gzip,
  lib,
  libiconv,
  libiconvReal,
  libpipeline,
  makeWrapper,
  nixosTests,
  pkg-config,
  stdenv,
  util-linuxMinimal,
  zstd,
}:

let
  libiconv' =
    if stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isFreeBSD then libiconvReal else libiconv;
in
stdenv.mkDerivation rec {
  pname = "man-db";
  version = "2.13.1";

  src = fetchurl {
    url = "mirror://savannah/man-db/man-db-${version}.tar.xz";
    hash = "sha256-iv67b362u4VCkpRYhB9cfm8kDjDIY1jB+8776gdsh9k=";
  };

  outputs = [
    "out"
    "doc"
  ];
  outputMan = "out"; # users will want `man man` to work

  strictDeps = true;
  nativeBuildInputs = [
    groff
    makeWrapper
    pkg-config
    zstd
  ];
  buildInputs = [
    libpipeline
    gdbm
    groff
    libiconv'
  ]; # (Yes, 'groff' is both native and build input)
  nativeCheckInputs = [ libiconv' ]; # for 'iconv' binary; make very sure it matches buildinput libiconv

  patches = [
    ./systemwide-man-db-conf.patch
  ];

  postPatch = ''
    # Remove all mandatory manpaths. Nixpkgs makes no requirements on
    # these directories existing.
    sed -i 's/^MANDATORY_MANPATH/# &/' src/man_db.conf.in

    # Add Nix-related manpaths
    echo "MANPATH_MAP	/nix/var/nix/profiles/default/bin	/nix/var/nix/profiles/default/share/man" >> src/man_db.conf.in

    # Add mandb locations for the above
    echo "MANDB_MAP	/nix/var/nix/profiles/default/share/man	/var/cache/man/nixpkgs" >> src/man_db.conf.in
  '';

  configureFlags = [
    "--disable-setuid"
    "--disable-cache-owner"
    "--localstatedir=/var"
    "--with-config-file=${placeholder "out"}/etc/man_db.conf"
    "--with-systemdtmpfilesdir=${placeholder "out"}/lib/tmpfiles.d"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-pager=less"
  ]
  ++ lib.optionals util-linuxMinimal.hasCol [
    "--with-col=${util-linuxMinimal}/bin/col"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "ac_cv_func__set_invalid_parameter_handler=no"
    "ac_cv_func_posix_fadvise=no"
    "ac_cv_func_mempcpy=no"
  ]
  ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    "--enable-mandirs="
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-sections=1 n l 8 3 0 2 5 4 9 6 7")
  '';

  postInstall = ''
    # apropos/whatis uses program name to decide whether to act like apropos or whatis
    # (multi-call binary). `apropos` is actually just a symlink to whatis. So we need to
    # make sure that we don't wrap symlinks (since that changes argv[0] to the -wrapped name)
    find "$out/bin" -type f | while read file; do
      wrapProgram "$file" \
        --prefix PATH : "${
          lib.makeBinPath [
            groff
            gzip
            zstd
          ]
        }"
    done
  '';

  disallowedReferences = lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    buildPackages.groff
  ];

  enableParallelBuilding = true;

  doCheck =
    !stdenv.hostPlatform.isMusl # iconv binary
  ;

  passthru.tests = {
    nixos = nixosTests.man;
  };

  meta = with lib; {
    homepage = "http://man-db.nongnu.org";
    description = "Implementation of the standard Unix documentation system accessed using the man command";
    license = licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "man";
  };
}
