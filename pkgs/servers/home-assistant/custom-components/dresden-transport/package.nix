{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  unstableGitUpdater,
}:

buildHomeAssistantComponent rec {
  owner = "SuperSandro2000";
  domain = "dresden_transport";
  version = "0-unstable-2026-05-20";

  src = fetchFromGitHub {
    inherit owner;
    repo = "home-assistant-transport";
    rev = "05c52b008cec0d6a62b6927fbf257c71805b555c";
    hash = "sha256-fRIzTo+sbjkekC4m2AxVHurRPv6zJ01q0T2LCJ1uhIY=";
  };

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Berlin (BVG), Brandenburg (VBB) and Dresden (VVO) transport widgets for Home Assistant";
    homepage = "https://github.com/SuperSandro2000/home-assistant-transport";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    platforms = lib.platforms.all;
  };
}
