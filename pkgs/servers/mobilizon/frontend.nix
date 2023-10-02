{ lib, callPackage, buildNpmPackage, imagemagick }:

let
  common = callPackage ./common.nix { };
in
buildNpmPackage {
  inherit (common) pname version src;

  npmDepsHash = "sha256-z/xWumL1wri63cGGMHMBq6WVDe81bp8tILsZa53a7FM=";

  nativeBuildInputs = [ imagemagick ];

  postInstall = ''
    cp -r priv/static $out/static
  '';

  dontStrip = true; # fixupPhase completed in 4 minutes 24 seconds

  meta = with lib; {
    description = "Frontend for the Mobilizon server";
    homepage = "https://joinmobilizon.org/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ minijackson erictapen ];
  };
}
