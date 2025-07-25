{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.glitchtip;
  pkg = cfg.package;
  inherit (pkg.passthru) python;

  environment = lib.mapAttrs (
    _: value:
    if value == true then
      "True"
    else if value == false then
      "False"
    else
      toString value
  ) cfg.settings;
in

{
  meta.maintainers = with lib.maintainers; [
    defelo
    felbinger
  ];

  options = {
    services.glitchtip = {
      enable = lib.mkEnableOption "GlitchTip";

      package = lib.mkPackageOption pkgs "glitchtip" { };

      user = lib.mkOption {
        type = lib.types.str;
        description = "The user account under which GlitchTip runs.";
        default = "glitchtip";
      };

      group = lib.mkOption {
        type = lib.types.str;
        description = "The group under which GlitchTip runs.";
        default = "glitchtip";
      };

      listenAddress = lib.mkOption {
        type = lib.types.str;
        description = ''
          The address to listen on.
          This option is ignored when using `nginx.createLocally` as that uses a unix socket.
        '';
        default = "127.0.0.1";
        example = "0.0.0.0";
      };

      port = lib.mkOption {
        type = lib.types.port;
        description = ''
          The port to listen on.
          This option is ignored when using `nginx.createLocally` as that uses a unix socket.
        '';
        default = 8000;
      };

      settings = lib.mkOption {
        description = ''
          Configuration of GlitchTip. See <https://glitchtip.com/documentation/install#configuration> for more information and required settings.
        '';
        default = { };
        defaultText = lib.literalExpression ''
          {
            DEBUG = 0;
            DEBUG_TOOLBAR = 0;
            DATABASE_URL = lib.mkIf config.services.glitchtip.database.createLocally "postgresql://@/glitchtip";
            REDIS_URL = lib.mkIf config.services.glitchtip.redis.createLocally "unix://''${config.services.redis.servers.glitchtip.unixSocket}";
            CELERY_BROKER_URL = lib.mkIf config.services.glitchtip.redis.createLocally "redis+socket://''${config.services.redis.servers.glitchtip.unixSocket}";
          }
        '';
        example = {
          GLITCHTIP_DOMAIN = "https://glitchtip.example.com";
          DATABASE_URL = "postgres://postgres:postgres@postgres/postgres";
        };

        type = lib.types.submodule {
          freeformType =
            with lib.types;
            attrsOf (oneOf [
              str
              int
              bool
            ]);

          options = {
            GLITCHTIP_DOMAIN = lib.mkOption {
              type = lib.types.str;
              description = "The URL under which GlitchTip is externally reachable.";
              example = "https://glitchtip.example.com";
            };

            ENABLE_USER_REGISTRATION = lib.mkOption {
              type = lib.types.bool;
              description = ''
                When true, any user will be able to register. When false, user self-signup is disabled after the first user is registered. Subsequent users must be created by a superuser on the backend and organization invitations may only be sent to existing users.
              '';
              default = false;
            };

            ENABLE_ORGANIZATION_CREATION = lib.mkOption {
              type = lib.types.bool;
              description = ''
                When false, only superusers will be able to create new organizations after the first. When true, any user can create a new organization.
              '';
              default = false;
            };
          };
        };
      };

      environmentFiles = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        example = [ "/run/secrets/glitchtip.env" ];
        description = ''
          Files to load environment variables from in addition to [](#opt-services.glitchtip.settings).
          This is useful to avoid putting secrets into the nix store.
          See <https://glitchtip.com/documentation/install#configuration> for more information.
        '';
      };

      database.createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable and configure a local PostgreSQL database server.";
      };

      nginx = {
        createLocally = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable and configure a local Nginx server.";
        };

        domain = lib.mkOption {
          type = lib.types.str;
          example = "glitchtip.example.com";
          description = ''
            Domain under which GlitchTip will be reachable.
            In contrast to `settings.GLITCHTIP_DOMAIN` this option has no protocol.
            It will also set `settings.GLITCHTIP_DOMAIN` with the `https://` protocol.
          '';
        };
      };

      redis.createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable and configure a local Redis instance.";
      };

      gunicorn.extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Extra arguments for gunicorn.";
      };

      celery.extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Extra arguments for celery.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    warnings =
      lib.optional (cfg.nginx.createLocally -> (cfg.listenAddress != "127.0.0.1" || cfg.port != 8000))
        "When services.glitchtip.nginx.createLocally is turned on, services.glitchtip.listenAddress and services.glitchtip.port have no effect.";

    services.glitchtip = {
      gunicorn.extraArgs = lib.mkMerge [
        (lib.mkIf (!cfg.nginx.createLocally) [
          "--bind=${cfg.listenAddress}:${toString cfg.port}"
        ])
        (lib.mkIf cfg.nginx.createLocally [
          "--bind=/run/glitchtip/glitchtip.sock"
          "--keep-alive=65"
        ])
      ];
      settings = {
        DEBUG = lib.mkDefault 0;
        DEBUG_TOOLBAR = lib.mkDefault 0;
        PYTHONPATH = "${python.pkgs.makePythonPath pkg.propagatedBuildInputs}:${pkg}/lib/glitchtip";
        DATABASE_URL = lib.mkIf cfg.database.createLocally "postgresql://@/glitchtip";
        REDIS_URL = lib.mkIf cfg.redis.createLocally "unix://${config.services.redis.servers.glitchtip.unixSocket}";
        CELERY_BROKER_URL = lib.mkIf cfg.redis.createLocally "redis+socket://${config.services.redis.servers.glitchtip.unixSocket}";
        GLITCHTIP_DOMAIN = lib.mkIf cfg.nginx.createLocally "https://${cfg.nginx.domain}";
        GLITCHTIP_VERSION = pkg.version;
      };
    };

    systemd.services =
      let
        commonServiceConfig = {
          User = cfg.user;
          Group = cfg.group;
          StateDirectory = "glitchtip";
          EnvironmentFile = cfg.environmentFiles;
          WorkingDirectory = "${pkg}/lib/glitchtip";

          # hardening
          AmbientCapabilities = "";
          CapabilityBoundingSet = [ "" ];
          DevicePolicy = "closed";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          RestrictAddressFamilies = [ "AF_INET AF_INET6 AF_UNIX" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];
          UMask = "0077";
        };
      in
      {
        glitchtip = {
          description = "GlitchTip";
          inherit environment;
          bindsTo = [ "glitchtip-worker.service" ];
          requires =
            lib.optional cfg.database.createLocally "postgresql.target"
            ++ lib.optional cfg.redis.createLocally "redis-glitchtip.service"
            ++ lib.optional cfg.nginx.createLocally "glitchtip.socket";
          after = [
            "glitchtip-worker.service"
            "network-online.target"
          ]
          ++ lib.optional cfg.database.createLocally "postgresql.service"
          ++ lib.optional cfg.redis.createLocally "redis-glitchtip.service"
          ++ lib.optional cfg.nginx.createLocally "glitchtip.socket";
          wants = [ "network-online.target" ];

          preStart = "${lib.getExe pkg} migrate";

          serviceConfig = commonServiceConfig // {
            ExecStart = ''
              ${lib.getExe python.pkgs.gunicorn} \
                ${lib.concatStringsSep " " cfg.gunicorn.extraArgs} \
                glitchtip.wsgi
            '';
            RuntimeDirectory = "glitchtip";
          };
        };

        glitchtip-worker = {
          description = "GlitchTip Job Runner";
          inherit environment;
          wants = [ "glitchtip.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = commonServiceConfig // {
            ExecStart = ''
              ${lib.getExe python.pkgs.celery} \
                -A glitchtip worker \
                -B -s /run/glitchtip/celerybeat-schedule \
                ${lib.concatStringsSep " " cfg.celery.extraArgs}
            '';
          };
        };
      };

    systemd.sockets = lib.mkIf cfg.nginx.createLocally {
      glitchtip.socketConfig = {
        ListenStream = "/run/glitchtip/glitchtip.sock";
        SocketUser = "nginx";
      };
    };

    services.nginx = lib.mkIf cfg.nginx.createLocally {
      enable = true;
      upstreams.glitchtip.servers."unix:/run/glitchtip/glitchtip.sock" = { };
      virtualHosts.${cfg.nginx.domain} = {
        forceSSL = lib.mkDefault true;
        locations = {
          "/".proxyPass = "http://glitchtip";
          "/static/" = {
            root = cfg.package;
            extraConfig = ''
              rewrite ^/(.*)$ /lib/glitchtip/$1 break;
            '';
          };
        };
      };
    };

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "glitchtip" ];
      ensureUsers = [
        {
          name = "glitchtip";
          ensureDBOwnership = true;
        }
      ];
    };

    services.redis.servers.glitchtip.enable = cfg.redis.createLocally;

    users.users = lib.mkIf (cfg.user == "glitchtip") {
      glitchtip = {
        home = "/var/lib/glitchtip";
        group = cfg.group;
        extraGroups = lib.optionals cfg.redis.createLocally [ "redis-glitchtip" ];
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "glitchtip") { glitchtip = { }; };

    environment.systemPackages =
      let
        glitchtip-manage = pkgs.writeShellScriptBin "glitchtip-manage" ''
          set -o allexport
          ${lib.toShellVars environment}
          ${lib.concatMapStringsSep "\n" (f: "source ${f}") cfg.environmentFiles}
          ${config.security.wrapperDir}/sudo -E -u ${cfg.user} ${lib.getExe pkg} "$@"
        '';
      in
      [ glitchtip-manage ];
  };
}
