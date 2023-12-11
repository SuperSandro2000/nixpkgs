{ fetchFromGitLab, applyPatches }: rec {

  pname = "mobilizon";
  version = "4.0.2";

  src = applyPatches {
    src = fetchFromGitLab {
      domain = "framagit.org";
      owner = "framasoft";
      repo = pname;
      rev = version;
      sha256 = "sha256-Ri1qCiQaKlSTSSGWHzFqYBCoTEMtOtwe0Kli466dv4M=";
    };

    patches = [
      ./allow-ldap-login-with-username.diff
    ];
  };
}
