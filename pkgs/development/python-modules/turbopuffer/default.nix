{
  lib,
  aiohttp,
  anyio,
  buildPythonPackage,
  dirty-equals,
  distro,
  fetchFromGitHub,
  hatch-fancy-pypi-readme,
  hatchling,
  httpx,
  numpy,
  orjson,
  pybase64,
  pydantic,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  respx,
  sniffio,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "turbopuffer";
  version = "2.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "turbopuffer";
    repo = "turbopuffer-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UhyxcRhrgmNYlI5UBFOzyiXj0KEGrTL5/Qy1c6nYNgQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "hatchling==1.26.3" "hatchling" \
      --replace-fail 'addopts = "--tb=short -n auto --dist loadgroup"' ""
  '';

  build-system = [
    hatch-fancy-pypi-readme
    hatchling
  ];

  dependencies = [
    aiohttp
    anyio
    distro
    httpx
    orjson
    pybase64
    pydantic
    sniffio
    typing-extensions
  ];

  nativeCheckInputs = [
    dirty-equals
    numpy
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
    respx
  ];

  pythonImportsCheck = [ "turbopuffer" ];

  disabledTestPaths = [
    # requires credential
    "tests/custom"
  ];

  meta = {
    description = "Official Python library for the turbopuffer API";
    homepage = "https://github.com/turbopuffer/turbopuffer-python";
    changelog = "https://github.com/turbopuffer/turbopuffer-python/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
