{
  lib,
  stdenv,
  fetchFromGitHub,
  libbpf,
  elfutils,
  zlib,
  libpcap,
  bpftools,
  llvmPackages,
  pkg-config,
  m4,
  wireshark-cli,
  nukeReferences,
}:
stdenv.mkDerivation rec {
  pname = "xdp-tools";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "xdp-project";
    repo = "xdp-tools";
    rev = "v${version}";
    hash = "sha256-dK+ZpD1wv20iU51dsMUiW/Z9jojuwC8P3rrjU3LEB1Y=";
  };

  outputs = [
    "out"
    "lib"
  ];

  buildInputs = [
    libbpf
    elfutils
    libpcap
    zlib
  ];

  nativeBuildInputs = [
    bpftools
    llvmPackages.clang
    llvmPackages.llvm
    pkg-config
    m4
    nukeReferences
  ];
  nativeCheckInputs = [
    wireshark-cli # for tshark
  ];

  hardeningDisable = [ "zerocallusedregs" ];
  # When building BPF, the default CC wrapper is interfering a bit too much.
  BPF_CFLAGS = "-fno-stack-protector -Wno-error=unused-command-line-argument";

  PRODUCTION = 1;
  DYNAMIC_LIBXDP = 1;
  FORCE_SYSTEM_LIBBPF = 1;

  makeFlags = [
    "PREFIX=$(out)"
    "LIBDIR=$(lib)/lib"
  ];

  postInstall = ''
    # Note that even the static libxdp would refer to BPF_OBJECT_DIR ?=$(LIBDIR)/bpf
    rm "$lib"/lib/*.a
    # Drop unfortunate references to glibc.dev/include at least from $lib
    nuke-refs "$lib"/lib/bpf/*.o
  '';

  meta = with lib; {
    homepage = "https://github.com/xdp-project/xdp-tools";
    description = "Library and utilities for use with XDP";
    license = with licenses; [
      gpl2Only
      lgpl21
      bsd2
    ];
    maintainers = with maintainers; [
      tirex
      vcunat
      vifino
    ];
    platforms = platforms.linux;
  };
}
