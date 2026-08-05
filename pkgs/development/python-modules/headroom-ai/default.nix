{
  lib,
  anthropic,
  ast-grep-cli,
  buildPythonPackage,
  click,
  datasets,
  fastapi,
  fastembed,
  fetchFromGitHub,
  httpx,
  huggingface-hub,
  jinja2,
  litellm,
  magika,
  mcp,
  numpy,
  onnxruntime,
  openai,
  openpyxl,
  opentelemetry-api,
  opentelemetry-exporter-otlp-proto-http,
  opentelemetry-sdk,
  orjson,
  pillow,
  pydantic,
  pyyaml,
  rapidocr,
  rapidocr-onnxruntime,
  rich,
  rustPlatform,
  scikit-learn,
  sentence-transformers,
  sentencepiece,
  sqlite-vec,
  starlette,
  tiktoken,
  tomlkit,
  torch,
  trafilatura,
  transformers,
  tree-sitter,
  tree-sitter-language-pack,
  uvicorn,
  watchdog,
  websockets,
  xlrd,
  zstandard,
}:

buildPythonPackage (finalAttrs: {
  pname = "headroom-ai";
  version = "0.34.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chopratejas";
    repo = "headroom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Pz/3R3xogTyREJ1yz/Kxj6OrtJbT9kwmWt5CaFQhrRE=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-NOflRqKu4fFYA06rZUoFlr8xPi750/AdD8vnFTtf6Tk=";
  };

  postPatch = ''
    # substituteInPlace headroom/cli/wrap.py \
    #   --replace-fail \
    #     '[sys.executable, "-m", "headroom.cli", "proxy",' \
    #     '["headroom", "proxy",'
  '';

  # nativeBuildInputs = [
  #   cffi
  # ];

  # buildInputs = [ onnxruntime ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  # env = {
  #   ORT_DYLIB_PATH = "${onnxruntime}/lib/libonnxruntime${stdenv.hostPlatform.extensions.sharedLibrary}";
  # };

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  dependencies = [
    ast-grep-cli
    click
    litellm
    opentelemetry-api
    pydantic
    pyyaml
    rich
    tiktoken
    tomlkit
  ];

  # only a selection of all optional-dependencies
  optional-dependencies = {
    proxy = [
      fastapi
      httpx
      magika
      mcp
      onnxruntime
      openai
      orjson
      sqlite-vec
      transformers
      uvicorn
      watchdog
      websockets
      zstandard
    ]
    ++ httpx.optional-dependencies.http2;
    code = [
      tree-sitter
      tree-sitter-language-pack
    ];
    ml = [
      huggingface-hub
      torch
      transformers
    ];
    memory = [
      sentence-transformers
      sqlite-vec
    ];
    relevance = [
      fastembed
      numpy
    ];
    image = [
      pillow
      sentencepiece
      rapidocr-onnxruntime
      rapidocr
      onnxruntime
    ];
    reports = [ jinja2 ];
    otel = [
      opentelemetry-sdk
      opentelemetry-exporter-otlp-proto-http
    ];
    evals = [
      datasets
      sentence-transformers
      numpy
      scikit-learn
      anthropic
      openai
    ];
    voice = [
      onnxruntime
      transformers
      torch
    ];
    html = [ trafilatura ];
    mcp = [
      mcp
      httpx
      starlette
      uvicorn
    ];
    spreadsheet = [
      openpyxl
      xlrd
    ];
    all =
      finalAttrs.passthru.optional-dependencies.proxy
      ++ finalAttrs.passthru.optional-dependencies.code
      ++ finalAttrs.passthru.optional-dependencies.ml
      ++ finalAttrs.passthru.optional-dependencies.memory
      ++ finalAttrs.passthru.optional-dependencies.relevance
      ++ finalAttrs.passthru.optional-dependencies.image
      ++ finalAttrs.passthru.optional-dependencies.reports
      ++ finalAttrs.passthru.optional-dependencies.otel
      ++ finalAttrs.passthru.optional-dependencies.evals
      ++ finalAttrs.passthru.optional-dependencies.voice
      ++ finalAttrs.passthru.optional-dependencies.html
      ++ finalAttrs.passthru.optional-dependencies.mcp
      ++ finalAttrs.passthru.optional-dependencies.spreadsheet;
  };

  # pythonRelaxDeps = [ "litellm" ];

  # doCheck = false;

  pythonImportsCheck = [ "headroom" ];

  meta = {
    description = "The Context Optimization Layer for LLM Applications - Cut costs by 50-90%";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    changelog = "https://github.com/headroomlabs-ai/headroom/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    mainProgram = "headroom";
  };
})
