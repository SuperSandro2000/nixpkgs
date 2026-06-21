{
  lib,
  fetchFromGitHub,
  python3,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "graphite";
  version = "2.7.5";

  src = fetchFromGitHub {
    owner = "TilmanGriesel";
    repo = "graphite";
    tag = version;
    hash = "sha256-eqP560lwpGw/SSa+IMZO7VsA/EoWP9HVncpPx+f6I9k=";
  };

  nativeBuildInputs = [ (python3.withPackages (ps: with ps; [ pyyaml ])) ];

  buildFlags = [ "theme" ];

  installPhase = ''
    runHook preInstall
    install -Dt $out/themes themes/*.yaml
    runHook postInstall
  '';

  passthru.isHomeAssistantTheme = true;

  meta = {
    description = "Calm and Clean Theme for Home Assistant";
    homepage = "https://github.com/TilmanGriesel/graphite";
    changelog = "https://github.com/TilmanGriesel/graphite/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
