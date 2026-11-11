{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  aiohttp,
  pytestCheckHook,
  pytest-asyncio,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "jevclient";
  version = "1.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AboveColin";
    repo = "jevclient";
    tag = finalAttrs.version;
    hash = "sha256-2g/97E2PoceTIie93G++wQEyjJJuQhFY6D/+9E44OGE=";
  };

  build-system = [ setuptools ];

  dependencies = [ aiohttp ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  pythonImportsCheck = [ "jevclient" ];

  meta = {
    description = "Async client for TypeSafe Jev, the System One decision model";
    homepage = "https://github.com/AboveColin/jevclient";
    changelog = "https://github.com/AboveColin/jevclient/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
