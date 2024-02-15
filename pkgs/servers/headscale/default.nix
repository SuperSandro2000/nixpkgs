{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nixosTests,
}:
buildGoModule rec {
  pname = "headscale";
  version = "0.23.0-alpha4";

  src = fetchFromGitHub {
    owner = "juanfont";
    repo = "headscale";
    rev = "v${version}";
    hash = "sha256-8qsm0OGAwKtGwMm3g4jUxhOLH9v9YS7iTi+JoMtvMc0=";
  };

  vendorHash = "sha256-tK42AnCPOBngixyo71WAWB9p76E4ugVpmeSPhtmuwuI=";

  ldflags = ["-s" "-w" "-X github.com/juanfont/headscale/cmd/headscale/cli.Version=v${version}"];

  nativeBuildInputs = [installShellFiles];
  checkFlags = ["-short"];

  subPackages = [ "cmd/headscale" ];
  tags = ["ts2019"];

  postInstall = ''
    installShellCompletion --cmd headscale \
      --bash <($out/bin/headscale completion bash) \
      --fish <($out/bin/headscale completion fish) \
      --zsh <($out/bin/headscale completion zsh)
  '';

  passthru.tests = { inherit (nixosTests) headscale; };

  meta = with lib; {
    homepage = "https://github.com/juanfont/headscale";
    description = "An open source, self-hosted implementation of the Tailscale control server";
    longDescription = ''
      Tailscale is a modern VPN built on top of Wireguard. It works like an
      overlay network between the computers of your networks - using all kinds
      of NAT traversal sorcery.

      Everything in Tailscale is Open Source, except the GUI clients for
      proprietary OS (Windows and macOS/iOS), and the
      'coordination/control server'.

      The control server works as an exchange point of Wireguard public keys for
      the nodes in the Tailscale network. It also assigns the IP addresses of
      the clients, creates the boundaries between each user, enables sharing
      machines between users, and exposes the advertised routes of your nodes.

      Headscale implements this coordination server.
    '';
    license = licenses.bsd3;
    maintainers = with maintainers; [nkje jk kradalby misterio77 ghuntley];
  };
}
