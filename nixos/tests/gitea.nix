{
  system ? builtins.currentSystem,
  config ? { },
  giteaPackage ? pkgs.gitea,
  pkgs ? import ../.. { inherit system config; },
}:

with import ../lib/testing-python.nix { inherit system pkgs; };
with pkgs.lib;

let
  ## gpg --faked-system-time='20230301T010000!' --quick-generate-key snakeoil ed25519 sign
  signingPrivateKey = ''
    -----BEGIN PGP PRIVATE KEY BLOCK-----

    lFgEY/6jkBYJKwYBBAHaRw8BAQdADXiZRV8RJUyC9g0LH04wLMaJL9WTc+szbMi7
    5fw4yP8AAQCl8EwGfzSLm/P6fCBfA3I9znFb3MEHGCCJhJ6VtKYyRw7ktAhzbmFr
    ZW9pbIiUBBMWCgA8FiEE+wUM6VW/NLtAdSixTWQt6LZ4x50FAmP+o5ACGwMFCQPC
    ZwAECwkIBwQVCgkIBRYCAwEAAh4FAheAAAoJEE1kLei2eMedFTgBAKQs1oGFZrCI
    TZP42hmBTKxGAI1wg7VSdDEWTZxut/2JAQDGgo2sa4VHMfj0aqYGxrIwfP2B7JHO
    GCqGCRf9O/hzBA==
    =9Uy3
    -----END PGP PRIVATE KEY BLOCK-----
  '';
  signingPrivateKeyId = "4D642DE8B678C79D";
  hosts = nodes: ''
    ${nodes.server.networking.primaryIPAddress} gitea.test
  '';

  supportedDbTypes = [
    "mysql"
    "postgres"
    "sqlite3"
  ];
  makeGiteaTest =
    type:
    nameValuePair type (makeTest {
      name = "${giteaPackage.pname}-${type}";
      meta.maintainers = with maintainers; [
        SuperSandro2000
        techknowlogick
      ];

      nodes = {
        server =
          {
            nodes,
            pkgs,
            ...
          }:
          {
            virtualisation.memorySize = 2047;
            networking.extraHosts = hosts nodes;
            networking.firewall.allowedTCPPorts = [ 80 ];
            services.gitea = {
              enable = true;
              database = { inherit type; };
              package = giteaPackage;
              configureNginx = true;
              metricsTokenFile = (pkgs.writeText "metrics_secret" "fakesecret").outPath;
              settings = {
                "repository.signing".SIGNING_KEY = signingPrivateKeyId;
                actions.ENABLED = true;
                metrics.ENABLED = true;
                picture.DISABLE_GRAVATAR = true;
                server = {
                  DOMAIN = "gitea.test";
                  ROOT_URL = "http://gitea.test";
                };
                service.DISABLE_REGISTRATION = true;
              };
            };
            environment.systemPackages = [
              giteaPackage
              pkgs.gnupg
              pkgs.jq
            ];
            services.openssh.enable = true;

            specialisation.runner = {
              inheritParentConfig = true;

              configuration.services.gitea-actions-runner.instances."test" = {
                enable = true;
                name = "ci";
                url = "http://gitea.test";
                labels = [
                  # don't require docker/podman
                  "native:host"
                ];
                tokenFile = "/var/lib/gitea/runner_token";
              };
            };
          };
        client1 =
          {
            nodes,
            pkgs,
            ...
          }:
          {
            environment.systemPackages = [ pkgs.git ];
            networking.extraHosts = hosts nodes;
          };
        client2 =
          {
            nodes,
            pkgs,
            ...
          }:
          {
            environment.systemPackages = with pkgs; [
              git
              jq
            ];
            networking.extraHosts = hosts nodes;
          };
      };

      testScript =
        { nodes, ... }:
        let
          inherit (import ./ssh-keys.nix pkgs) snakeOilPrivateKey snakeOilPublicKey;
          serverSystem = nodes.server.system.build.toplevel;
        in
        ''
          GIT_SSH_COMMAND = "ssh -i $HOME/.ssh/privk -o StrictHostKeyChecking=no"
          REPO = "gitea@gitea.test:test/repo"
          PRIVK = "${snakeOilPrivateKey}"

          start_all()

          client1.succeed("mkdir /tmp/repo")
          client1.succeed("mkdir -p $HOME/.ssh")
          client1.succeed(f"cat {PRIVK} > $HOME/.ssh/privk")
          client1.succeed("chmod 0400 $HOME/.ssh/privk")
          client1.succeed("git -C /tmp/repo init")
          client1.succeed("echo hello world > /tmp/repo/testfile")
          client1.succeed("git -C /tmp/repo add .")
          client1.succeed("git config --global user.email test@gitea.test")
          client1.succeed("git config --global user.name test")
          client1.succeed("git -C /tmp/repo commit -m 'Initial import'")
          client1.succeed(f"git -C /tmp/repo remote add origin {REPO}")

          server.wait_for_unit("gitea.service")
          server.wait_for_open_port(22)
          server.wait_for_open_port(80)
          server.wait_for_file("/run/gitea/gitea.sock")
          server.succeed("curl --fail http://gitea.test/")

          server.succeed(
              "su -l gitea -c 'gpg --homedir /var/lib/gitea/data/home/.gnupg "
              + "--import ${toString (pkgs.writeText "gitea.key" signingPrivateKey)}'"
          )

          assert "BEGIN PGP PUBLIC KEY BLOCK" in server.succeed("curl http://gitea.test/api/v1/signing-key.gpg")

          server.succeed(
              "curl --fail http://gitea.test/user/sign_up | grep 'Registration is disabled. "
              + "Please contact your site administrator.'"
          )
          server.succeed(
              "su -l gitea -c 'GITEA_WORK_DIR=/var/lib/gitea gitea admin user create "
              + "--username test --password totallysafe --email test@gitea.test'"
          )

          api_token = server.succeed(
              "curl --fail -X POST http://test:totallysafe@gitea.test/api/v1/users/test/tokens "
              + "-H 'Accept: application/json' -H 'Content-Type: application/json' -d "
              + "'{\"name\":\"token\",\"scopes\":[\"all\"]}' | jq '.sha1' | xargs echo -n"
          )

          server.succeed(
              "curl --fail -X POST http://gitea.test/api/v1/user/repos "
              + "-H 'Accept: application/json' -H 'Content-Type: application/json' "
              + f"-H 'Authorization: token {api_token}'"
              + ' -d \'{"auto_init":false, "description":"string", "license":"mit", "name":"repo", "private":false}\'''
          )

          server.succeed(
              "curl --fail -X POST http://gitea.test/api/v1/user/keys "
              + "-H 'Accept: application/json' -H 'Content-Type: application/json' "
              + f"-H 'Authorization: token {api_token}'"
              + ' -d \'{"key":"${snakeOilPublicKey}","read_only":true,"title":"SSH"}\'''
          )

          client1.succeed(
              f"GIT_SSH_COMMAND='{GIT_SSH_COMMAND}' git -C /tmp/repo push origin master"
          )

          client2.succeed("mkdir -p $HOME/.ssh")
          client2.succeed(f"cat {PRIVK} > $HOME/.ssh/privk")
          client2.succeed("chmod 0400 $HOME/.ssh/privk")
          client2.succeed(f"GIT_SSH_COMMAND='{GIT_SSH_COMMAND}' git clone {REPO}")
          client2.succeed('test "$(cat repo/testfile | xargs echo -n)" = "hello world"')

          client1.succeed(
              "curl --fail http://gitea.test/static/assets/img/favicon.png --output /dev/null"
          )

          client2.succeed(
              "curl --fail $(curl http://gitea.test/api/v1/users/test 2> /dev/null | jq -r .avatar_url) --output /dev/null"
          )

          server.wait_until_succeeds(
              'test "$(curl http://gitea.test/api/v1/repos/test/repo/commits '
              + '-H "Accept: application/json" | jq length)" = "1"'
          )

          with subtest("Testing metrics endpoint"):
              server.succeed('curl '
                             + '-H "Authorization: Bearer fakesecret" '
                             + 'http://gitea.test/metrics '
                             + '| grep gitea_accesses')

          with subtest("Testing runner registration"):
              server.succeed(
                  "su -l gitea -c 'GITEA_WORK_DIR=/var/lib/gitea gitea actions generate-runner-token' | sed 's/^/TOKEN=/' | tee /var/lib/gitea/runner_token"
              )
              server.succeed("${serverSystem}/specialisation/runner/bin/switch-to-configuration test")
              server.wait_for_unit("gitea-runner-test.service")
              server.succeed("journalctl -o cat -u gitea-runner-test.service | grep -q 'Runner registered successfully'")
        '';
    });
in

listToAttrs (map makeGiteaTest supportedDbTypes)
