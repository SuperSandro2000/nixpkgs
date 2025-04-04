{
  lib,
  buildNimPackage,
  fetchFromGitHub,
  pcre,
  versionCheckHook,
}:

buildNimPackage (finalAttrs: {
  pname = "mosdepth";
  version = "0.3.10";

  requiredNimVersion = 1;

  src = fetchFromGitHub {
    owner = "brentp";
    repo = "mosdepth";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RAE3k2yA2zsIr5JFYb5bPaMzdoEKms7TKaqVhPS5LzY=";
  };

  lockFile = ./lock.json;

  buildInputs = [ pcre ];
  nativeBuildInputs = [ versionCheckHook ];

  nimFlags = [ ''--passC:"-Wno-incompatible-pointer-types"'' ];

  doInstallCheck = true;

  meta = with lib; {
    description = "fast BAM/CRAM depth calculation for WGS, exome, or targeted sequencing";
    mainProgram = "mosdepth";
    license = licenses.mit;
    homepage = "https://github.com/brentp/mosdepth";
    maintainers = with maintainers; [
      jbedo
      ehmry
    ];
    platforms = platforms.linux;
  };
})
