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
stdenv.mkDerivation (finalAttrs: {
  pname = "airplay-cli";
  version = "0.4.13";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "music-assistant";
    repo = "airplay-cli";
    # we try to closely match the version used in the last music-assistant release from
    # https://github.com/music-assistant/server/blob/stable/Dockerfile#L7
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-XqYOQ1HaZu4lvLU7bVEahVSAa72nWZ3ypjjAfty0YOw=";
  };

  postPatch = ''
    # the most security critical part we build ourself
    rm -r libraop/libopenssl/

    # easen debugging and we strip ourselves, too
    substituteInPlace Makefile \
      --replace-fail "LDFLAGS += -s" "LDFLAGS +="
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # on darwin the direct dlopen to system libcrypto crashes with
    # WARNING: /nix/store/.../bin/cliraop is loading libcrypto in an unsafe way
    # Abort trap: 6
    substituteInPlace libraop/crosstools/src/cross_ssl.c \
      --replace-fail '"libcrypto.dylib"' '"${lib.getLib openssl}/lib/libcrypto.dylib"' \
      --replace-fail '"libssl.dylib"' '"${lib.getLib openssl}/lib/libssl.dylib"'
  '';

  buildInputs = [
    openssl
  ];

  makeFlags = [
    "HOST=${host}"
    "PLATFORM=${stdenv.hostPlatform.uname.processor}"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/cliairplay-${host}-${stdenv.hostPlatform.uname.processor} $out/bin/cliairplay
  '';

  meta = {
    description = "Unified command-line binary for streaming to AirPlay 1 (RAOP) and AirPlay 2 devices";
    homepage = "https://github.com/music-assistant/airplay-cli";
    license =
      with lib.licenses;
      AND [
        gpl2Plus
        asl20
      ];
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    mainProgram = "cliairplay";
    platforms = with lib.platforms; linux ++ darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
