{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  home-assistant-intents,
  pytestCheckHook,
  pyyaml,
  setuptools,
  unicode-rbnf,
}:

buildPythonApplication (finalAttrs: {
  pname = "gazetteer-matcher";
  version = "1.1.0";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "OHF-Voice";
    repo = "gazetteer-matcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iy5xybM8ZWlVElC2ubjxdGNj2kgKo1ZTk7Pup8e6WyY=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    home-assistant-intents
    pyyaml
    unicode-rbnf
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "gazetteer_matcher"
  ];

  meta = {
    description = "Constraint-driven intent recognizer for Home Assistant voice commands";
    homepage = "https://github.com/OHF-Voice/gazetteer-matcher";
    changelog = "https://github.com/OHF-Voice/gazetteer-matcher/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "gazetteer-matcher";
  };
})
