{ lib
, buildNpmPackage
, fetchFromGitHub
, fetchpatch
}:

buildNpmPackage rec {
  pname = "auto-entities";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-auto-entities";
    rev = "refs/tags/${version}";
    hash = "sha256-yeIgE1YREmCKdjHAWlUf7RfDZfC+ww3+jR/8AdKtZ7U=";
  };

  prePatch = ''
    rm .gitattributes
  '';

  patches = [
    ./fix-package-lock-json.diff

    (fetchpatch {
      url = "https://github.com/thomasloven/lovelace-auto-entities/pull/164.diff";
      excludes = [ "auto-entities.js" ];
      hash = "sha256-9XmCJc+XMmyqiSKrX4i5ADp6G5ueE2/6aLDKSvv/RK0=";
    })
    (fetchpatch {
      url = "https://github.com/thomasloven/lovelace-auto-entities/pull/309.diff";
      excludes = [ "auto-entities.js" ];
      hash = "sha256-frkMWu7nWgKZTjyFtmd11Ad4E2ppI3i4giB4eIC+2+g=";
    })
    (fetchpatch {
      url = "https://github.com/thomasloven/lovelace-auto-entities/pull/343.diff";
      excludes = [ "auto-entities.js" ];
      hash = "sha256-J36ETsbfsY4sMZsNVGJfol3T1d2s0yVUxSX7/fECkik=";
    })
    (fetchpatch {
      url = "https://github.com/thomasloven/lovelace-auto-entities/pull/415.diff";
      hash = "sha256-q/o2nXc5ou+WxrhSzjR/jDEsH/71a/E9fkwTUjkiVdg=";
    })
  ];

  npmDepsHash = "sha256-yZgpb/TgFmZEjckhehukqBVtzUlMlO26dH75MfiqY2s=";

  makeCacheWritable = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -v auto-entities.js* $out/

    runHook postInstall
  '';

  passthru.entrypoint = "auto-entities.js";

  meta = with lib; {
    description = "Automatically populate the entities-list of lovelace cards";
    homepage = "https://github.com/thomasloven/lovelace-auto-entities";
    changelog = "https://github.com/thomasloven/lovelace-auto-entities/releases/tag/${version}";
    maintainers = with maintainers; [ SuperSandro2000 ];
    license = licenses.mit;
  };
}
