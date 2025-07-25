{
  stdenv,
  lib,
  fetchurl,
  clang,
  llvm,
  pkg-config,
  makeWrapper,
  elfutils,
  file,
  jansson,
  libbpf_0,
  libcap_ng,
  libevent,
  libmaxminddb,
  libnet,
  libnetfilter_log,
  libnetfilter_queue,
  libnfnetlink,
  libpcap,
  libyaml,
  luajit,
  lz4,
  nspr,
  pcre2,
  python3,
  vectorscan,
  zlib,
  redisSupport ? true,
  valkey,
  hiredis,
  rustSupport ? true,
  rustc,
  cargo,
  nixosTests,
}:
let
  libmagic = file;
in
stdenv.mkDerivation rec {
  pname = "suricata";
  version = "7.0.10";

  src = fetchurl {
    url = "https://www.openinfosecfoundation.org/download/${pname}-${version}.tar.gz";
    hash = "sha256-GX+SXqcBvctKFaygJLBlRrACZ0zZWLWJWPKaW7IU11k=";
  };

  nativeBuildInputs = [
    clang
    llvm
    makeWrapper
    pkg-config
  ]
  ++ lib.optionals rustSupport [
    rustc
    cargo
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pyyaml
  ];

  buildInputs = [
    elfutils
    jansson
    libbpf_0
    libcap_ng
    libevent
    libmagic
    libmaxminddb
    libnet
    libnetfilter_log
    libnetfilter_queue
    libnfnetlink
    libpcap
    libyaml
    luajit
    lz4
    nspr
    pcre2
    python3
    vectorscan
    zlib
  ]
  ++ lib.optionals redisSupport [
    valkey
    hiredis
  ];

  enableParallelBuilding = true;

  patches = lib.optional stdenv.hostPlatform.is64bit ./bpf_stubs_workaround.patch;

  postPatch = ''
    substituteInPlace ./configure \
      --replace "/usr/bin/file" "${file}/bin/file"
    substituteInPlace ./libhtp/configure \
      --replace "/usr/bin/file" "${file}/bin/file"

    mkdir -p bpf_stubs_workaround/gnu
    touch bpf_stubs_workaround/gnu/stubs-32.h
  '';

  configureFlags = [
    "--disable-gccmarch-native"
    "--enable-af-packet"
    "--enable-ebpf"
    "--enable-ebpf-build"
    "--enable-gccprotect"
    "--enable-geoip"
    "--enable-luajit"
    "--enable-nflog"
    "--enable-nfqueue"
    "--enable-pie"
    "--enable-python"
    "--enable-unix-socket"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--with-libhs-includes=${lib.getDev vectorscan}/include/hs"
    "--with-libhs-libraries=${lib.getLib vectorscan}/lib"
    "--with-libnet-includes=${libnet}/include"
    "--with-libnet-libraries=${libnet}/lib"
  ]
  ++ lib.optional redisSupport "--enable-hiredis"
  ++ lib.optionals rustSupport [
    "--enable-rust"
    "--enable-rust-experimental"
  ];

  postConfigure = ''
    # Avoid unintended clousure growth.
    sed -i 's|${builtins.storeDir}/\(.\{8\}\)[^-]*-|${builtins.storeDir}/\1...-|g' ./src/build-info.h
  '';

  # zerocallusedregs interferes during BPF compilation; TODO: perhaps improve
  hardeningDisable = [
    "stackprotector"
    "zerocallusedregs"
  ];

  doCheck = true;

  installFlags = [
    "e_datadir=\${TMPDIR}"
    "e_localstatedir=\${TMPDIR}"
    "e_logdir=\${TMPDIR}"
    "e_logcertsdir=\${TMPDIR}"
    "e_logfilesdir=\${TMPDIR}"
    "e_rundir=\${TMPDIR}"
    "e_sysconfdir=\${out}/etc/suricata"
    "e_sysconfrulesdir=\${out}/etc/suricata/rules"
    "localstatedir=\${TMPDIR}"
    "runstatedir=\${TMPDIR}"
    "sysconfdir=\${out}/etc"
  ];

  installTargets = [
    "install"
    "install-conf"
  ];

  postInstall = ''
    wrapProgram "$out/bin/suricatasc" \
      --prefix PYTHONPATH : $PYTHONPATH:$(toPythonPath "$out")
    substituteInPlace "$out/etc/suricata/suricata.yaml" \
      --replace "/etc/suricata" "$out/etc/suricata"
  '';

  passthru.tests = { inherit (nixosTests) suricata; };

  meta = with lib; {
    description = "Free and open source, mature, fast and robust network threat detection engine";
    homepage = "https://suricata.io";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ magenbluten ];
  };
}
