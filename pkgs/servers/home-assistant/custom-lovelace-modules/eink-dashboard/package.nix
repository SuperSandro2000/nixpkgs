{
  home-assistant-custom-components,
  stdenv,
}:

stdenv.mkDerivation {
  inherit (home-assistant-custom-components.eink-dashboard)
    pname
    version
    meta
    ;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp ${home-assistant-custom-components.eink-dashboard}/custom_components/eink_dashboard/frontend/*.js{,.map} $out/

    runHook postInstall
  '';

  passthru.entrypoint = "eink-dashboard-card.js";
}
