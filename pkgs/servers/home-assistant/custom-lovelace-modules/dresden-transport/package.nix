{
  buildNpmPackage,
  home-assistant-custom-components,
}:

buildNpmPackage {
  inherit (home-assistant-custom-components.dresden-transport)
    pname
    version
    src
    meta
    ;

  npmDepsHash = "sha256-c8+2nyimolCeXjgUa6lrEVVPB6mR/FK94fPonsO9C9U=";

  npmBuildScript = "rollup";

  installPhase = ''
    install dist/dresden-transport-card.js -Dt $out
  '';

  passthru.entrypoint = "dresden-transport-card.js";
}
