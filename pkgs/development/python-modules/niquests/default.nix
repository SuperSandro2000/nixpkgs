{
  aiofiles,
  buildPythonPackage,
  charset-normalizer,
  cryptography,
  fastapi,
  fetchFromGitHub,
  hatchling,
  lib,
  orjson,
  pytest-asyncio,
  pytest-httpbin,
  pytestCheckHook,
  stdenv,
  urllib3-future,
  wassima,
}:

buildPythonPackage (finalAttrs: {
  pname = "niquests";
  version = "3.21.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jawah";
    repo = "niquests";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0OVZeX7nFIdB7fMcmu4eutobfSJ7GVqBvSh1PeMtV3k=";
  };

  build-system = [ hatchling ];

  dependencies = [
    charset-normalizer
    urllib3-future
    wassima
  ];

  optional-dependencies = {
    inherit (urllib3-future.optional-dependencies)
      brotli
      socks
      ws
      ws-fast
      zstd
      ;
    full = [
      orjson
    ]
    ++ urllib3-future.optional-dependencies.brotli
    ++ urllib3-future.optional-dependencies.socks
    ++ urllib3-future.optional-dependencies.qh3
    ++ urllib3-future.optional-dependencies.ws
    ++ urllib3-future.optional-dependencies.zstd;
    http3 = urllib3-future.optional-dependencies.qh3;
    ocsp = urllib3-future.optional-dependencies.qh3;
    speedups = [
      orjson
    ]
    ++ urllib3-future.optional-dependencies.brotli
    ++ urllib3-future.optional-dependencies.zstd;
  };

  pythonImportsCheck = [ "niquests" ];

  nativeCheckInputs = [
    aiofiles
    cryptography
    fastapi
    pytest-asyncio
    pytest-httpbin
    pytestCheckHook
  ];

  disabledTestPaths = [
    # tests connect to the internet
    "tests/test_requests.py"
    # we don't care about coverage
    "tests/wasi_guest/coverage_runner.py"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # NameResolutionError: Failed to resolve 'localhost'
    "tests/test_rate_limiters.py"
    "tests/test_lowlevel.py"
    "tests/test_testserver.py"
    # ssl.SSLCertVerificationError: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1032)
    "tests/test_crl.py"
    "tests/test_live.py"
    "tests/test_ocsp.py"
    "tests/test_sse.py"
  ];

  disabledTests =
    [
      # This niquests test fails because its dependency urllib3-future is incompatible with python-socks v3.
      # urllib3-future's maintainers declined v3 support and plan to replace their optional python-socks dependency.
      # https://github.com/jawah/urllib3.future/issues/437
      "test_use_proxy_from_environment"
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      "test_docker_version_info"
      "test_docker_404_unknown_path"
    ];

  meta = {
    changelog = "https://github.com/jawah/niquests/blob/${finalAttrs.src.tag}/HISTORY.md";
    description = "Simple HTTP library that is a drop-in replacement for Requests";
    homepage = "https://github.com/jawah/niquests";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
