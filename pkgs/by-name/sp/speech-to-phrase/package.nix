{
  lib,
  bash,
  diffutils,
  fetchFromGitHub,
  gawk,
  gzip,
  home-assistant,
  kaldi,
  opengrm-ngram,
  perl,
  phonetisaurus,
  runCommand,
}:

let
  inherit (home-assistant) python3Packages;

  tools = runCommand "speech-to-phrase-tools" { } ''
    mkdir -p $out/kaldi
    ln -s ${kaldi}/{bin,lib} $out/kaldi
    cp -r ${kaldi}/share/kaldi/egs/wsj/s5/{steps,utils} $out/kaldi
    ln -s ${kaldi} $out/openfst

    ln -s ${opengrm-ngram} $out/opengrm
    # The binary phonetisaurus in the download identifies itself as phonetisaurus-g2pfst when run with --help
    ln -s ${lib.getExe' phonetisaurus "phonetisaurus-g2pfst"} $out/phonetisaurus
  '';
  # stt_onlyprobs
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "speech-to-phrase";
  version = "1.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "OHF-voice";
    repo = "speech-to-phrase";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3ki/Vj/MXOszjlhFQ/Z30dhlnPKUhdJ6PPPN1r/KAi4=";
  };

  patches = [
    # ERROR: Fst::Write: Can't open file: -
    ./fix-stdout.diff
  ];

  postPatch = ''
    # allow us to load the home-assistant token securely
    substituteInPlace speech_to_phrase/__main__.py \
      --replace-fail 'import argparse' 'import argparse; import os' \
      --replace-fail '"--hass-token", required=True' ' "--hass-token", default=os.environ.get("HASS_TOKEN")'

    # flags in opensft changed semantics
    substituteInPlace speech_to_phrase/{transcribe_coqui_stt.py,transcribe_kaldi.py} \
      --replace-fail "--project_type=output" "--project_output=true"
  '';

  pythonRelaxDeps = true;

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    aiohttp
    hassil
    pyring-buffer
    pysilero-vad
    pyyaml
    regex
    ruamel-yaml
    unicode-rbnf
    wyoming
  ];

  pythonImportsCheck = [ "speech_to_phrase" ];

  postFixup = ''
    buildPythonPath "$out ''${pythonPath[*]}"
    # we must add way to many scripting tools to PATH to contains kaldi's scripting hell
    makeWrapper ${python3Packages.python.interpreter} $out/bin/speech-to-phrase \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          diffutils
          gawk
          gzip
          kaldi
          perl
          python3Packages.python
        ]
      } \
      --prefix PYTHONPATH : "$program_PYTHONPATH" \
      --add-flags "-m speech_to_phrase" \
      --add-flags "--tools-dir ${tools}"
  '';

  nativeCheckInputs = with python3Packages; [
    home-assistant.intents
    kaldi
    opengrm-ngram # for ngrammake
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
    voluptuous
  ];

  disabledTestPaths = [
    # requires connecting to huggingface.co
    "tests/test_transcribe.py"
  ];

  meta = {
    changelog = "https://github.com/OHF-Voice/speech-to-phrase/releases/tag/${finalAttrs.src.tag}";
    homepage = "https://github.com/OHF-Voice/speech-to-phrase";
    description = "Fast and personalized local speech-to-text";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    mainProgram = "speech-to-phrase";
  };
})
