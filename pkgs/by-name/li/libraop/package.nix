{
  lib,
  fetchFromGitHub,
  openssl,
  stdenv,
}:

let
  host =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "macos"
    else
      throw "libraop does not support this platform, yet";
in
stdenv.mkDerivation {
  pname = "libraop";
  version = "0.0.0-unstable-2026-02-09";

  src = fetchFromGitHub {
    owner = "music-assistant";
    repo = "libraop";
    # we try to closely match the commit used in the last music-assistant release from
    # https://github.com/music-assistant/server/tree/dev/music_assistant/providers/airplay/bin
    rev = "f49284282ea4ea740d07fabc230b4182f8c69a74";
    fetchSubmodules = true;
    hash = "sha256-m1ll5vRZx4d/5IWCG24yY/SWEIIz2k/iU84vQKHlCdo=";
  };

  postPatch = ''
    # the most security critical part we build ourself
    rm -r libopenssl/

    # do not confuse the prebuilt binaries with the ones we build
    rm bin/*
  '';

  buildInputs = [
    openssl
  ];

  makeFlags = [
    "HOST=${host}"
    "PLATFORM=${stdenv.hostPlatform.linuxArch}"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/cliraop-${host}-${stdenv.hostPlatform.linuxArch} $out/bin/cliraop
  '';

  meta = {
    description = "RAOP player and library (AirPlay)";
    homepage = "https://github.com/music-assistant/libraop";
    # https://github.com/philippe44/libraop/issues/36
    license = with lib.licenses; [
      gpl2Only
      mit
    ];
    maintainers = [ ];
    mainProgram = "cliraop";
    platforms = with lib.platforms; linux ++ darwin;
  };
}
