{
  lib,
  bun,
  fetchFromGitHub,
  fetchurl,
  linkFarm,
  postgresql,
  postgresqlTestHook,
  python3Packages,
}:
let
  appDependencies =
    ps:
    with ps;
    [
      alembic
      cashews
      cloudevents
      fastapi
      fastapi-pagination
      google-genai
      greenlet
      httpx
      json-repair
      lancedb
      langfuse
      nanoid
      openai
      pdfplumber
      pgvector
      prometheus-client
      psycopg
      pyarrow
      pydantic
      pydantic-settings
      pyjwt
      python-dotenv
      redis
      rich
      scikit-learn
      sentry-sdk
      sqlalchemy
      tenacity
      tiktoken
      turbopuffer
      typing-extensions
    ]
    ++ cashews.optional-dependencies.redis
    ++ fastapi.optional-dependencies.standard
    ++ sentry-sdk.optional-dependencies.anthropic
    ++ sentry-sdk.optional-dependencies.fastapi
    ++ sentry-sdk.optional-dependencies.sqlalchemy;

  pythonEnv = python3Packages.python.withPackages appDependencies;
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "honcho";
  version = "3.0.12";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "plastic-labs";
    repo = "honcho";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nsDb1zumWJYHI9O1RLj1BlNbMGmwCERb1LeYmkS7jM8=";
  };

  pythonRelaxDeps = [
    "redis"
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = appDependencies python3Packages;

  installPhase = ''
    mkdir -p $out/share/honcho
    cp -r \
      src \
      migrations \
      scripts \
      alembic.ini \
      config.toml.example \
      $out/share/honcho

    makeWrapper ${pythonEnv}/bin/fastapi $out/bin/honcho-api \
      --set PYTHONPATH "$out/share/honcho" \
      --add-flags "run src/main.py"

    makeWrapper ${pythonEnv.interpreter} "$out/bin/honcho-derive" \
      --set PYTHONPATH "$out/share/honcho" \
      --add-flags "-m src.deriver"

    makeWrapper ${pythonEnv.interpreter} "$out/bin/honcho-migrate" \
      --set PYTHONPATH "$out/share/honcho" \
      --add-flags "-m alembic upgrade head"
  '';

  postgresqlEnableTCP = true;
  nativeCheckInputs = with python3Packages; [
    bun
    fakeredis
    (postgresql.withPackages (p: [ p.pgvector ]))
    postgresqlTestHook
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
    sqlalchemy-utils
  ];

  disabledTestPaths = [
    # we do not need to run bun's typecheck
    "tests/sdk_typescript/"
    # re-executes python
    "tests/startup/test_embedding_validator.py::test_non_1536_pgvector_without_migrated_no_longer_raises_at_config_time"
    # our fastapi is newer
    "tests/routes/test_auth_route_policy.py::test_every_message_route_requires_auth"
    "tests/routes/test_auth_route_policy.py::test_member_read_allowlist_matches_routes"
  ];

  env = {
    TIKTOKEN_CACHE_DIR = linkFarm "honcho-tiktoken-cache" [
      {
        name = "9b5ad71b2ce5302211f9c61530b329a4922fc6a4";
        path = fetchurl {
          url = "https://web.archive.org/web/20260723164258/https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken";
          hash = "sha256-Ijkht27pm96ZW3/3OFE+7xAPtR0YyTWXoRO8/+hlsqc=";
        };
      }
      {
        name = "fb374d419588a4632f3f557e76b4b70aebbca790";
        path = fetchurl {
          url = "https://web.archive.org/web/20260727061535/https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken";
          hash = "sha256-RGqVOMtsNI41FhINfAiwn1fDZJXirP/+WaW/iwz7Gi0=";
        };
      }
    ];
  };

  meta = {
    description = "Memory library for building stateful agents";
    homepage = "https://github.com/plastic-labs/honcho";
    changelog = "https://github.com/plastic-labs/honcho/blob/v${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
