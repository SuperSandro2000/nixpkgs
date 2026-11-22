{
  lib,
  aiotools,
  bleak-esphome,
  buildHomeAssistantComponent,
  fetchNpmDeps,
  fetchFromGitHub,
  homeassistant,
  kaitai-struct-compiler,
  kaitaistruct,
  npmHooks,
  nodejs_26,
  pytest-homeassistant-custom-component,
  pytest-freezer,
  pytest-xdist,
  pytestCheckHook,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "teh-hippo";
  domain = "ha_govee_led_ble";
  version = "7.41.0";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "ha-govee-led-ble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jbAksbwnaBBMhKOaAnX3xh0onY0OiEysiFPKbWUYF5s=";
  };

  patches = [ ./ha-2026.11.patch ];

  postPatch = ''
    echo ${lib.versions.majorMinor nodejs_26.version} > .node-version
    substituteInPlace Makefile \
      --replace-fail 'SHELL := /usr/bin/env bash' 'SHELL := bash' \
      --replace-fail '[[ "$$actual" == "v$$expected" ]]' '[[ "$$actual" =~ ^v$$expected\.[0-9]+$$ ]]'
    substituteInPlace scripts/generate-frontend.sh \
      --replace-fail '[[ "$actual_node" != "v$expected_node" ]]' '[[ ! "$actual_node" =~ ^v$expected_node\.[0-9]+$ ]]'
    substituteInPlace tests/test_build.py \
      --replace-fail "/usr/bin/make" "make"
  '';

  npmRoot = "frontend";
  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/frontend";
    hash = "sha256-s+ky9PKo1HPYETytu1FHt4qpdflCwBLg1ppgRjvETGo=";
  };

  nativeBuildInputs = [
    kaitai-struct-compiler
    nodejs_26
    npmHooks.npmConfigHook
  ];

  dependencies = [
    kaitaistruct
  ];

  nativeCheckInputs = [
    aiotools
    bleak-esphome
    pytest-freezer
    pytest-homeassistant-custom-component
    pytest-xdist
    pytestCheckHook
  ]
  ++ (homeassistant.getPackages "bluetooth" homeassistant.python3Packages);

  disabledTestPaths = [
    # we have no git repo
    "tests/test_build.py"
    "tests/test_release_workflows.py"
    "tests/test_repository_boundaries.py"
    # The test changes hass.config.config_dir after its native Store cached the path.
    "tests/test_h6099_dreamview.py::test_dreamview_restoration_journal_outlives_native_enable_persistence"
    # These assert Home Assistant private APIs that changed in 2026.11.
    "tests/test_govee_encryption.py::test_h607c_registered_entities_present_identity_states"
    "tests/test_govee_encryption.py::test_h607c_registered_gradual_tracks_identity_and_release_reconnect"
    "tests/test_govee_encryption.py::test_h607c_registered_light_exposes_colour_uncertainty_and_assumed_retry"
    "tests/test_h6099_dreamview.py::test_storage_failure_prevents_transmission"
    # Its SimpleNamespace integration mock has no logger, unlike HA's real Integration.
    "tests/test_h6099_dreamview.py::test_dreamview_disconnect_failure_does_not_poison_native_entry_unload"
  ];

  meta = {
    changelog = "https://github.com/teh-hippo/ha-govee-led-ble/releases/tag/${finalAttrs.src.tag}";
    description = "Govee LED Bluetooth integration for Home Assistant";
    homepage = "https://github.com/teh-hippo/ha-govee-led-ble";
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    license = lib.licenses.mit;
  };
})
