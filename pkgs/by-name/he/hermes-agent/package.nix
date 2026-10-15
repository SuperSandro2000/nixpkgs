{
  lib,
  fetchFromGitHub,
  makeWrapper,
  python3Packages,
  stdenvNoCC,

  optionalDependencyNames ? [ ],

  # runtime dependencies
  ffmpeg-headless,
  git,
  nodejs,
  openssh,
  ripgrep,
  wl-clipboard,
  xclip,
}:
let
  pname = "hermes-agent";
  version = "0.22.2";

  src = fetchFromGitHub {
    owner = "NousResearch";
    repo = "hermes-agent";
    tag = "v${version}";
    hash = "sha256-i9rob9jtBv6XTV0acNbHDEUM+9f3ZsN1zJkD6dMBzTc=";
  };

  meta = {
    homepage = "https://github.com/NousResearch/hermes-agent";
    description = "The self-improving AI agent — creates skills from experience, improves them during use, and runs anywhere";
    changelog = "https://github.com/NousResearch/hermes-agent/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      SuperSandro2000
    ];
    mainProgram = "hermes-agent";
  };

  hermes-agent-pkg = python3Packages.buildPythonPackage (finalAttrs: {
    inherit pname version src;
    pyproject = true;

    env = {
      HERMES_NIX_BUILD = 1;
    };

    nativeBuildInputs = [
      python3Packages.pyprojectVersionPatchHook
    ];

    build-system = [
      python3Packages.setuptools
    ];

    pythonRelaxDeps = true;

    pythonRemoveDeps = [
      "browser-harness" # not packaged
    ];

    dependencies =
      with python3Packages;
      [
        openai
        certifi
        truststore
        python-dotenv
        fire
        httpx
        rich
        tenacity
        tomli-w
        ruamel-yaml
        requests
        jinja2
        firecrawl-anydoc
        pydantic
        prompt-toolkit
        croniter
        snowballstemmer
        packaging
        markdown
        pyjwt
        urllib3
        cryptography
        tzdata
        psutil
        websockets
        # browser-harness # not packaged
        pathspec
        fastapi
        uvicorn
        httptools
        watchfiles
        python-multipart
        ptyprocess
        pillow
        pillow-heif
        resvg-py
        nemo-relay
      ]
      ++ httpx.optional-dependencies.socks
      ++ pyjwt.optional-dependencies.crypto;

    # Upstream adds dependencies for reasons we do not need to care at this point
    # like forcing transitive dependency updates to fix CVEs or bump transitive dependencies.
    # For that reason the following deps are omitted:
    # httpx, starlette, aiohttp
    optional-dependencies = with python3Packages; {
      uvloop = [ uvloop ];
      anthropic = [ anthropic ];
      exa = [ exa-py ];
      firecrawl = [ firecrawl-py ];
      # parallel-web = [ parallel-web ]; # not packaged
      # fal = [ fal-client ]; # not packaged
      ddgs = [ ddgs ];
      edge-tts = [ edge-tts ];
      # neutts = [ neutts ] ++ neutts.optional-dependencies.all; # not packaged
      # kittentts = [ kittentts misaki soundfile ] ++ misaki.optional-dependencies.en;
      piper = [ piper-tts ];
      modal = [ modal ];
      # daytona = [ daytona ]; # not packaged
      # vercel = [ vercel ]; # not packaged
      messaging = [
        python-telegram-bot
        discordpy
        brotlicffi
        slack-bolt
        slack-sdk
        qrcode
      ]
      ++ python-telegram-bot.optional-dependencies.webhooks
      ++ discordpy.optional-dependencies.voice;
      cron = [ ]; # kept for back-compat
      slack = [
        slack-bolt
        slack-sdk
        aiohttp
      ];
      matrix = [
        mautrix
        aiosqlite
        asyncpg
        aiohttp-socks
      ]
      ++ mautrix.optional-dependencies.encryption;
      wecom = [ defusedxml ];
      tts-premium = [ elevenlabs ];
      voice = [
        faster-whisper
        sounddevice
        numpy
      ];
      wake = [
        pyopen-wakeword
        sherpa-onnx
        sentencepiece
        pypinyin
        # pvporcupine # not packaged
        sounddevice
        numpy
      ];
      telegram = [ python-telegram-bot ] ++ python-telegram-bot.optional-dependencies.webhooks;
      discord = [ discordpy ] ++ discordpy.optional-dependencies.voice;
      stt-whisper = [ sounddevice numpy ];
      # silk = [ pilk ]; # not packaged
      wake-openwakeword = [ pyopen-wakeword ];
      wake-sherpa = [ sherpa-onnx sherpa-onnx-core sentencepiece pypinyin ];
      # wake-porcupine = [ pvporcupine ]; # not packaged
      google-chat = [ google-cloud-pubsub ];
      doc-extract = [ firecrawl-anydoc ];
      trace-upload = [ huggingface-hub ];
      vision = [ ]; # kept for back-compat
      pty = [ ]; # kept for back-compat
      mcp = [ mcp ];
      nemo-relay = [ ]; # kept for back-compat
      sms = [ aiohttp ];
      # teams = [ microsoft-teams-apps ]; # not packaged
      computer-use = [ mcp httpx2 ];
      acp = [ agent-client-protocol ];
      mistral = [ mistralai ];
      otlp = [
        opentelemetry-sdk
        opentelemetry-exporter-otlp-proto-http
      ];
      bedrock = [ boto3 ];
      vertex = [ google-auth ];
      azure-identity = [ azure-identity ];
      termux = [
        python-telegram-bot
      ]
      ++ python-telegram-bot.optional-dependencies.webhooks
      ++ finalAttrs.passthru.optional-dependencies.cron
      ++ finalAttrs.passthru.optional-dependencies.mcp
      ++ finalAttrs.passthru.optional-dependencies.acp;
      termux-all =
        finalAttrs.passthru.optional-dependencies.termux
        ++ finalAttrs.passthru.optional-dependencies.google
        ++ finalAttrs.passthru.optional-dependencies.sms
        ++ finalAttrs.passthru.optional-dependencies.web
        ++ finalAttrs.passthru.optional-dependencies.pty;
      # dingtalk = [ # not packaged
      #   # dingtalk-stream
      #   # alibabacloud-dingtalk
      #   qrcode
      # ];
      feishu = [
        lark-oapi
        qrcode
      ];
      google = [
        google-api-python-client
        google-auth
        google-auth-oauthlib
        google-auth-httplib2
      ];
      youtube = [
        youtube-transcript-api
      ];
      web = [
        fastapi
        uvicorn
        python-multipart
      ];
      all =
        finalAttrs.passthru.optional-dependencies.cron
        ++ finalAttrs.passthru.optional-dependencies.pty
        ++ finalAttrs.passthru.optional-dependencies.mcp
        ++ finalAttrs.passthru.optional-dependencies.uvloop
        ++ finalAttrs.passthru.optional-dependencies.sms
        ++ finalAttrs.passthru.optional-dependencies.acp
        ++ finalAttrs.passthru.optional-dependencies.google
        ++ finalAttrs.passthru.optional-dependencies.web
        ++ finalAttrs.passthru.optional-dependencies.youtube;
    };

    inherit meta;
  });
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hermes-agent $out/bin
    cp -r ${src}/skills $out/share/hermes-agent/skills
    cp -r ${src}/optional-skills $out/share/hermes-agent/optional-skills
    cp -r ${src}/plugins $out/share/hermes-agent/plugins
    cp -r ${src}/locales $out/share/hermes-agent/locales
    cp -r ${src}/optional-mcps $out/share/hermes-agent/optional-mcps
    # cp -r ''${hermesWeb} $out/share/hermes-agent/web_dist
    # cp -r ''${hermesTui}/lib/hermes-tui $out/ui-tui

    for name in hermes hermes-agent hermes-acp; do
      makeWrapper ${hermes-agent-pkg}/bin/$name $out/bin/$name \
        --suffix PATH : ${
          lib.makeBinPath (
            [
              ffmpeg-headless
              git
              nodejs
              openssh
              ripgrep
            ]
            ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
              wl-clipboard
              xclip
            ]
          )
        } \
        --set HERMES_BUNDLED_SKILLS $out/share/hermes-agent/skills \
        --set HERMES_OPTIONAL_SKILLS $out/share/hermes-agent/optional-skills \
        --set HERMES_BUNDLED_PLUGINS $out/share/hermes-agent/plugins \
        --set HERMES_BUNDLED_LOCALES $out/share/hermes-agent/locales \
        --set HERMES_OPTIONAL_MCPS $out/share/hermes-agent/optional-mcps \
        --set HERMES_WEB_DIST $out/share/hermes-agent/web_dist \
        --set HERMES_TUI_DIR $out/ui-tui \
        --set-default HERMES_BIN $out/bin/hermes \
        --set HERMES_PYTHON ${lib.getExe hermes-agent-pkg} \
        --set HERMES_NODE ${lib.getExe nodejs} \
        --suffix PYTHONPATH : "${
          lib.makeSearchPath python3Packages.python.sitePackages (
            map (d: hermes-agent-pkg.passthru.optional-dependencies.${d}) optionalDependencyNames
          )
        }"
    done

    runHook postInstall
  '';

  passthru = {
    unwrapped = hermes-agent-pkg;
  };

  inherit meta;
}
