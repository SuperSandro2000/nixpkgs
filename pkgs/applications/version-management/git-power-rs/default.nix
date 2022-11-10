{ lib
, rustPlatform
, fetchFromGitHub
, openssl
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "git-power-rs";
  version = "unstable-2021-07-11";

  src = fetchFromGitHub {
    owner = "SuperSandro2000";
    repo = "git-power-rs";
    rev = "abcdef84a484ed6e2de1f58cd736ace77b990ce3";
    sha256 = "sha256-gCr0gn05a54v6MNG1Wr+bPctgjmrCRNCmYIVOcJPbJc=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  cargoSha256 = "sha256-8b9OlxuTtubkCMgzkQzi83GcVEvi1vtt6h3hSSpC94o=";

  meta = with lib; {
    description = "EmPOWer your commits with Rust!";
    homepage = "https://github.com/SuperSandro2000/git-power-rs";
    license = licenses.free;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
