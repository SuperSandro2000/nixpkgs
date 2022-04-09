{ lib
, beamPackages
, callPackage
, fetchFromGitLab
, fetchFromGitHub
, fetchgit
, git
, cmake
, nixosTests
, srcOverride ? null
}:

let
  inherit (beamPackages) mixRelease buildMix fetchHex;
in
mixRelease rec {
  pname = "mobilizon";
  version = "2.0.2";

  src = if srcOverride != null then srcOverride else fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = pname;
    rev = version;
    sha256 = "sha256-tEnnT4FnUrHU+05nBqGnPXR7CgAsbg5/rj9ur9+acEE=";
  };

  nativeBuildInputs = [ git cmake ];

  mixNixDeps = import ./mix.nix {
    inherit beamPackages lib;
    overrides = (final: prev: {
      fast_html = prev.fast_html.override {
        nativeBuildInputs = [ cmake ];
      };
      ex_cldr = prev.ex_cldr.overrideAttrs (old: {
        preBuild = "touch config/prod.exs";
        # We have to use the GitHub sources, as it otherwise tries to download
        # the locales at build time.
        src = fetchFromGitHub {
          owner = "elixir-cldr";
          repo = "cldr";
          rev = "v2.24.2";
          sha256 = "sha256-7EukiuukF/ZfzlTg16BGvMvl1L8kSphaGPg1YqjL0EE=";
        };
        postInstall = ''
          cp $src/priv/cldr/locales/* $out/lib/erlang/lib/ex_cldr-${old.version}/priv/cldr/locales/
        '';
      });
      ex_cldr_currencies = prev.ex_cldr_currencies.override {
        preBuild = "touch config/prod.exs";
      };
      ex_cldr_numbers = prev.ex_cldr_numbers.override {
        preBuild = "touch config/prod.exs";
      };
      ex_cldr_dates_times = prev.ex_cldr_dates_times.override {
        preBuild = "touch config/prod.exs";
      };
      # Upstream issue: https://github.com/bryanjos/geo_postgis/pull/87
      geo_postgis = prev.geo_postgis.overrideAttrs (old: {
        propagatedBuildInputs = old.propagatedBuildInputs ++ [ final.ecto ];
      });

      # The remainder are Git dependencies (and their deps) that are not supported by mix2nix currently.
      icalendar = buildMix rec {
        name = "icalendar";
        version = "unstable-2021-01-15";
        src = fetchFromGitHub {
          owner = "tcitworld";
          repo = name;
          rev = "e16a3a0b74e07ba79044361fbf5014bed344f2da";
          sha256 = "sha256-tazBovTLqc5U6PEjVIKnxNNTdF12uh03cSYPybrC0zw=";
        };
        beamDeps = with final; [ mix_test_watch earmark ex_doc timex ];
      };
      earmark = buildMix rec {
        name = "earmark";
        version = "1.4.10";
        src = fetchHex {
          pkg = name;
          version = version;
          sha256 = "sha256-Etv6gIEEeOUh0/+5Qa2fv8u9fevpThNBtMShskEcHCc=";
        };
        beamDeps = with final; [ earmark_parser ];
      };
      ueberauth_keycloak_strategy = buildMix rec {
        name = "ueberauth_keycloak_strategy";
        version = "unstable-2021-06-29";
        src = fetchFromGitHub {
          owner = "tcitworld";
          repo = "ueberauth_keycloak";
          rev = "d892f0f9daf9e0023319b69ac2f7c2c6edff2b14";
          sha256 = "sha256-aDzAtRY7uzK8mgBfw868JglV7A9FHrKkRA9d/3+pkPY=";
        };
        # We skip exvcr here as it is dev-only and would require a huge amount
        # of packages.
        beamDeps = with final; [ oauth2 ueberauth credo earmark ex_doc ];
      };
      ueberauth_gitlab_strategy = buildMix rec {
        name = "ueberauth_gitlab_strategy";
        version = "unstable-2021-06-28";
        src = fetchFromGitHub {
          owner = "tcitworld";
          repo = "ueberauth_gitlab";
          rev = "9fc5d30b5d87ff7cdef293a1c128f25777dcbe59";
          sha256 = "sha256-yWHlhrDvw9VHiPvKUUtuTaTZ+DUjlKSuBbkOXk7pAcs=";
        };
        # We skip exvcr here as it is dev-only and would require a huge amount
        # of packages.
        beamDeps = with final; [ oauth2 ueberauth credo earmark ex_doc ];
      };
    });
  };

  # Install the compiled js part
  preBuild = let
    js = callPackage ./js.nix { mobilizon-src = src; };
  in ''
    cp -a "${js}/libexec/mobilizon/deps/priv/static" ./priv
  '';

  passthru.tests = {
    smoke-test = nixosTests.mobilizon;
  };

  meta = with lib; {
    description = "Mobilizon is an online tool to help manage your events, your profiles and your groups";
    homepage = "https://joinmobilizon.org/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ minijackson erictapen ];
  };
}
