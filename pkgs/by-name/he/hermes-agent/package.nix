{
  lib,
  fetchFromGitHub,
  fetchpatch,
  makeWrapper,
  python313Packages,
  stdenvNoCC,

  optionalDependencyNames ? [ ],

  # runtime dependencies
  ffmpeg-headless,
  git,
  nodejs,
  openssh,
  ripgrep,
  tirith,
  wl-clipboard,
  xclip,
}:
let
  pname = "hermes-agent";
  version = "0.20.1";

  src = fetchFromGitHub {
    owner = "NousResearch";
    repo = "hermes-agent";
    tag = "v2026.8.13"; # (¬_¬)
    hash = "sha256-A+pprddWqewhUjD8d+PLdTHAO5SZV6YwPhJrC2T2dFE=";
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

  pythonPackages = python313Packages;

  hermes-agent-pkg = pythonPackages.buildPythonPackage (finalAttrs: {
    inherit pname version src;
    pyproject = true;

    patches = [
      # Add registration lifecycle to pyproject.toml
      (fetchpatch {
        url = "https://github.com/NousResearch/hermes-agent/commit/89d3e43f5e61146bff46923dd8a9fc7a6cfc9d63.patch";
        hash = "sha256-x9VBWY0xs+YczVkwURKE/v78Fypn355Px0tV4Gf3frk=";
      })
    ];

    env = {
      HERMES_NIX_BUILD = 1;
    };

    build-system = [
      pythonPackages.setuptools
    ];

    pythonRelaxDeps = true;

    dependencies =
      with pythonPackages;
      [
        openai
        certifi
        python-dotenv
        fire
        httpx
        rich
        tenacity
        pyyaml
        ruamel-yaml
        requests
        jinja2
        pydantic
        prompt-toolkit
        croniter
        packaging
        markdown
        pyjwt
        urllib3
        cryptography
        psutil
        websockets
        pathspec
        fastapi
        uvicorn
        python-multipart
        ptyprocess
        pillow
        nemo-relay
      ]
      ++ httpx.optional-dependencies.socks
      ++ pyjwt.optional-dependencies.crypto
      ++ uvicorn.optional-dependencies.standard;

    optional-dependencies = with pythonPackages; {
      anthropic = [ anthropic ];
      exa = [ exa-py ];
      firecrawl = [ firecrawl-py ];
      # parallel-web = [ parallel-web ]; # not packaged
      # fal = [ fal-client ]; # not packaged
      edge-tts = [ edge-tts ];
      modal = [ modal ];
      # daytona = [ daytona ]; # not packaged
      # vercel = [ vercel ]; # not packaged
      # hindsight = [ hindsight-client ]; # not packaged
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
        # openwakeword # not packaged
        onnxruntime
        sherpa-onnx
        sentencepiece
        # pvporcupine # not packaged
        sounddevice
        numpy
      ]
      ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin ai-edge-litert;
      # honcho = [ honcho-ai ]; # not packaged
      # supermemory = [ supermemory ]; # not packaged
      # mem0 = [ mem0ai ]; # not packaged
      vision = [ ]; # kept for back-compat
      pty = [ ]; # kept for back-compat
      mcp = [ mcp ];
      homeassistant = [ aiohttp ];
      sms = [ aiohttp ];
      # teams = [ microsoft-teams-apps ]; # not packaged
      computer-use = [ mcp ];
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
      # ++ finalAttrs.passthru.optional-dependencies.honcho
      ++ finalAttrs.passthru.optional-dependencies.acp;
      termux-all =
        finalAttrs.passthru.optional-dependencies.termux
        ++ finalAttrs.passthru.optional-dependencies.google
        ++ finalAttrs.passthru.optional-dependencies.homeassistant
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
      ]
      ++ uvicorn.optional-dependencies.standard;
      all =
        finalAttrs.passthru.optional-dependencies.cron
        ++ finalAttrs.passthru.optional-dependencies.pty
        ++ finalAttrs.passthru.optional-dependencies.mcp
        ++ finalAttrs.passthru.optional-dependencies.homeassistant
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
              tirith
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
          lib.makeSearchPath pythonPackages.python.sitePackages (
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
