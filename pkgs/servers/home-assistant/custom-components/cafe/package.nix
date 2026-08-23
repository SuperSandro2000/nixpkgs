{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  nodejs,
  yarn-berry_4,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "FezVrasta";
  domain = "cafe";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "FezVrasta";
    repo = "cafe-hass";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jWHPR4nWZt4vtTF0KqNtzZoUCmL6hYrnncIgWAY9T0E=";
  };

  patches = [
    ./fix-lock.diff
  ];

  postPatch = ''
    substituteInPlace .yarnrc.yml \
      --replace-fail "yarnPath: .yarn/releases/yarn-4.12.0.cjs" ""
  '';

  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry_4.fetchYarnBerryDeps {
    inherit (finalAttrs)
      src
      patches
      postPatch
      missingHashes
      ;
    hash = "sha256-IpR07g5NNN9cXxuBbr7thfXC227dIAHlmEegfXkuqZ8=";
  };

  nativeBuildInputs = [
    nodejs
    yarn-berry_4
    yarn-berry_4.yarnBerryConfigHook
  ];

  preBuild = ''
    echo Building shared
    yarn workspace @cafe/shared build
    echo Building transpiler
    yarn workspace @cafe/transpiler build
    echo Building frontend
    yarn workspace @cafe/frontend build
  '';

  meta = {
    changelog = "https://github.com/FezVrasta/cafe-hass/releases/tag/${finalAttrs.src.tag}";
    description = "The \"Third Way\" for Home Assistant Automations";
    homepage = "https://github.com/FezVrasta/cafe-hass";
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    license = lib.licenses.mit;
  };
})
