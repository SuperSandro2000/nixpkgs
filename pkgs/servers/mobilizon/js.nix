{ lib, applyPatches, yarn, mkYarnPackage, imagemagick, mobilizon-src }:

mkYarnPackage rec {
  src = applyPatches {
    name = "mobilizon-js-src";
    src = "${mobilizon-src}/js";
    patches = [
      ./set-interval.patch
    ];
  };

  # redundant?
  yarnFlags = [ "--offline" ];

  packageJSON = ./package.json;
  yarnLock = "${src}/yarn.lock";
  yarnNix = ./yarn.nix;

  buildPhase = ''
    runHook preBuild

    # Tests cannot find the functions of the testing framework
    rm -r ./deps/mobilizon/tests
    yarn run build

    runHook postBuild
  '';

  nativeBuildInputs = [ imagemagick ];

  meta = with lib; {
    description = "Frontend for the Mobilizon server";
    homepage = "https://joinmobilizon.org/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ minijackson erictapen ];
  };
}
