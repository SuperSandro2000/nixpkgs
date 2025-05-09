{
  lib,
  beamPackages,
  fetchFromGitHub,
  fetchFromGitLab,
  fetchHex,
  file,
  cmake,
  nixosTests,
  writeText,
  vips,
  pkg-config,
  glib,
  fetchpatch,
  ...
}:

beamPackages.mixRelease rec {
  pname = "pleroma";
  version = "2.9.1";

  src = fetchFromGitLab {
    domain = "git.pleroma.social";
    owner = "pleroma";
    repo = "pleroma";
    rev = "v${version}";
    sha256 = "sha256-mZcr+LlRQFDZVU5yAm0XkFdFHCDp4DZNLoVUlWxknMI=";
  };

  patches = [ ./Revert-Config-Restrict-permissions-of-OTP-config.patch ];

  mixNixDeps = import ./mix.nix {
    inherit beamPackages lib;
    overrides = final: prev: {
      # Upstream is pointing to
      # https://github.com/feld/phoenix/commits/v1.7.14-websocket-headers/
      # which is v1.7.14 with an extra patch applied on top.
      phoenix = beamPackages.buildMix {
        name = "phoenix";
        version = "1.7.14-websocket-headers";
        src = fetchFromGitHub {
          owner = "phoenixframework";
          repo = "phoenix";
          tag = "v1.7.14";
          hash = "sha256-hb8k0bUl28re1Bv2AIs17VHOP8zIyCfbpaVydu1Dh24=";
        };
        patches = [
          (fetchpatch {
            name = "0001-Support-passing-through-the-value-of-the-sec-websocket-protocol-header.patch";
            url = "https://github.com/feld/phoenix/commit/fb6dc76c657422e49600896c64aab4253fceaef6.patch";
            hash = "sha256-eMla+D3EcVTc1WwlRaKvLPV5eXwGfAgZOxiYlGSkBIQ=";
          })
        ];
        beamDeps = with final; [
          phoenix_pubsub
          plug
          plug_crypto
          telemetry
          phoenix_template
          websock_adapter
          phoenix_view
          castore
          plug_cowboy
          jason
        ];
      };
      # mix2nix does not support git dependencies yet,
      # so we need to add them manually
      captcha = beamPackages.buildMix {
        name = "captcha";
        version = "0.1.0";

        src = fetchFromGitLab {
          domain = "git.pleroma.social";
          owner = "pleroma/elixir-libraries";
          repo = "elixir-captcha";
          rev = "90f6ce7672f70f56708792a98d98bd05176c9176";
          sha256 = "sha256-s7EuAhmCsQA/4p2NJHJSWB/DZ5hA+7EelPsUOvKr2Po=";
        };
        beamDeps = [ ];
      };
      prometheus_ex = beamPackages.buildMix {
        name = "prometheus_ex";
        version = "3.0.5";

        src = fetchFromGitHub {
          owner = "lanodan";
          repo = "prometheus.ex";
          rev = "31f7fbe4b71b79ba27efc2a5085746c4011ceb8f";
          hash = "sha256-2PZP+YnwnHt69HtIAQvjMBqBbfdbkRSoMzb1AL2Zsyc=";
        };
        beamDeps = with final; [ prometheus ];
      };
      remote_ip = beamPackages.buildMix {
        name = "remote_ip";
        version = "0.1.5";

        src = fetchFromGitLab {
          domain = "git.pleroma.social";
          owner = "pleroma/elixir-libraries";
          repo = "remote_ip";
          rev = "b647d0deecaa3acb140854fe4bda5b7e1dc6d1c8";
          hash = "sha256-pgON0uhTPVeeAC866Qz24Jvm1okoAECAHJrRzqaq+zA=";
        };
        beamDeps = with final; [
          combine
          plug
          inet_cidr
        ];
      };
      majic = prev.majic.override { buildInputs = [ file ]; };
      # Some additional build inputs and build fixes
      http_signatures = prev.http_signatures.override {
        patchPhase = ''
          substituteInPlace mix.exs --replace ":logger" ":logger, :public_key"
        '';
      };
      fast_html = prev.fast_html.override {
        nativeBuildInputs = [ cmake ];
        dontUseCmakeConfigure = true;
      };

      syslog = prev.syslog.override { buildPlugins = with beamPackages; [ pc ]; };

      vix = prev.vix.override {
        nativeBuildInputs = [ pkg-config ];
        buildInputs = [
          vips
          glib.dev
        ];
        VIX_COMPILATION_MODE = "PLATFORM_PROVIDED_LIBVIPS";
      };

      # This needs a different version (1.0.14 -> 1.0.18) to build properly with
      # our Erlang/OTP version.
      eimp = beamPackages.buildRebar3 rec {
        name = "eimp";
        version = "1.0.18";

        src = beamPackages.fetchHex {
          pkg = name;
          inherit version;
          sha256 = "0fnx2pm1n2m0zs2skivv43s42hrgpq9i143p9mngw9f3swjqpxvx";
        };

        patchPhase = ''
          echo '{plugins, [pc]}.' >> rebar.config
        '';
        buildPlugins = with beamPackages; [ pc ];

        beamDeps = with final; [ p1_utils ];
      };
      # Required by eimp
      p1_utils = beamPackages.buildRebar3 rec {
        name = "p1_utils";
        version = "1.0.18";

        src = fetchHex {
          pkg = "${name}";
          inherit version;
          sha256 = "120znzz0yw1994nk6v28zql9plgapqpv51n9g6qm6md1f4x7gj0z";
        };

        beamDeps = [ ];
      };

      mime = prev.mime.override {
        patchPhase =
          let
            cfgFile = writeText "config.exs" ''
              use Mix.Config
              config :mime, :types, %{
                "application/activity+json" => ["activity+json"],
                "application/jrd+json" => ["jrd+json"],
                "application/ld+json" => ["activity+json"],
                "application/xml" => ["xml"],
                "application/xrd+xml" => ["xrd+xml"]
              }
            '';
          in
          ''
            mkdir config
            cp ${cfgFile} config/config.exs
          '';
      };
    };
  };

  passthru = {
    tests.pleroma = nixosTests.pleroma;
    inherit mixNixDeps;
  };

  meta = with lib; {
    description = "ActivityPub microblogging server";
    homepage = "https://git.pleroma.social/pleroma/pleroma";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [
      picnoir
      kloenk
      yayayayaka
    ];
    platforms = platforms.unix;
  };
}
