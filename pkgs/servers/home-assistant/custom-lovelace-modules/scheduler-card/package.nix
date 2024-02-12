{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchpatch,
}:

buildNpmPackage rec {
  pname = "scheduler-card";
  version = "3.2.12";

  src = fetchFromGitHub {
    owner = "nielsfaber";
    repo = "scheduler-card";
    rev = "refs/tags/v${version}";
    hash = "sha256-M5W0CMnKuDrDqya1P8XkGBS9fPFLZ71NXqvm4Jb0pgc=";
  };

  patches = [
    # add package-lock.json
    # https://github.com/nielsfaber/scheduler-card/pull/799
    (fetchpatch {
      url = "https://github.com/nielsfaber/scheduler-card/commit/c840e9ac3f0591910c2b74044b444a282bef155d.patch";
      hash = "sha256-sD/tEcxizzcZQQJInOPr5V9BrIVfGf7+/C9Qv8KcQzo=";
    })
  ];

  npmDepsHash = "sha256-6mdayiktuwezxyuwvp6Iy1I3YMWdgngXjax/tbCjmB8=";

  npmBuildScript = "rollup";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -v dist/scheduler-card.js* $out/

    runHook postInstall
  '';

  passthru.entrypoint = "scheduler-card.js";

  meta = with lib; {
    description = "HA Lovelace card for control of scheduler entities";
    homepage = "https://github.com/nielsfaber/scheduler-card";
    changelog = "https://github.com/nielsfaber/scheduler-card/releases/tag/v${version}";
    maintainers = with maintainers; [ SuperSandro2000 ];
    license = licenses.isc;
  };
}
