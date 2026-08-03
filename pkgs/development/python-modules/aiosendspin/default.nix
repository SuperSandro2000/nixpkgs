{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pyprojectVersionPatchHook,

  # build-system
  setuptools,

  # dependencies
  aiohttp,
  av,
  cpace,
  cryptography,
  mashumaro,
  noiseprotocol,
  numpy,
  orjson,
  pillow,
  zeroconf,

  # test dependencies
  pytest-aiohttp,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,

  # meta
  music-assistant,

  nixosTests,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiosendspin";
  version = "7.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Sendspin";
    repo = "aiosendspin";
    tag = finalAttrs.version;
    hash = "sha256-jkywLGhCWgQx1pvLqgsCr8ozaFBuluM9S3y2q/VcKCI=";
  };

  postPatch = ''
    # too narrow timeouts, so remove pytest-timeout
    sed -i "/addopts/d" pyproject.toml
  '';

  build-system = [
    setuptools
  ];

  nativeBuildInputs = [
    # https://github.com/Sendspin/aiosendspin/blob/7.0.0/pyproject.toml#L30
    pyprojectVersionPatchHook
  ];

  dependencies = [
    aiohttp
    cpace
    cryptography
    mashumaro
    noiseprotocol
    orjson
    zeroconf
  ];

  optional-dependencies = {
    server = [
      av
      numpy
      pillow
    ];
  };

  nativeCheckInputs = [
    pytest-aiohttp
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.server;

  pythonImportsCheck = [
    "aiosendspin"
  ];

  passthru = {
    # needs manual compat testing with music-assistant (sendspin provider)
    skipBulkUpdate = true; # nixpkgs-update: no auto update
    tests = nixosTests.music-assistant;
  };

  meta = {
    changelog = "https://github.com/Sendspin/aiosendspin/releases/tag/${finalAttrs.src.tag}";
    description = "Async Python library implementing the Sendspin Protocol";
    homepage = "https://github.com/Sendspin/aiosendspin";
    license = lib.licenses.asl20;
    inherit (music-assistant.meta) maintainers;
  };
})
