{
  lib,
  mkKdeDerivation,
  qttools,
  accounts-qt,
  kaccounts-integration,
  shared-mime-info,
  xz,
  withMariaDB ? true,
  mariadb,
  withPostgreSQL ? false,
  postgresql,
  withSQLite ? false,
  sqlite,
  defaultBackend ? "MYSQL",
}:

assert (withMariaDB || withPostgreSQL || withSQLite);
assert lib.assertOneOf "defaultBackend" defaultBackend [
  "MYSQL"
  "POSTGRES"
  "SQLITE"
];

assert defaultBackend == "MYSQL" -> withMariaDB;
assert defaultBackend == "POSTGRES" -> withPostgreSQL;
assert defaultBackend == "SQLITE" -> withSQLite;

mkKdeDerivation {
  pname = "akonadi";

  patches = [
    # Always regenerate MySQL config, as the store paths don't have accurate timestamps
    ./ignore-mysql-config-timestamp.patch
  ];

  extraCmakeFlags =
    [ "-DDATABASE_BACKEND=${defaultBackend}" ]
    ++ lib.optionals withMariaDB [
      "-DMYSQLD_SCRIPTS_PATH=${lib.getBin mariadb}/bin"
    ]
    ++ lib.optionals withPostgreSQL [
      "-DPOSTGRES_PATH=${lib.getBin postgresql}/bin"
    ];

  extraNativeBuildInputs = [
    qttools
    shared-mime-info
  ];

  extraBuildInputs =
    [
      kaccounts-integration
      accounts-qt
      xz
    ]
    ++ lib.optionals withMariaDB [ mariadb ]
    ++ lib.optionals withPostgreSQL [ postgresql ]
    ++ lib.optionals withSQLite [ sqlite ];

  # Hardcoded as a QString, which is UTF-16 so Nix can't pick it up automatically
  postFixup = ''
    mkdir -p $out/nix-support
     ${lib.optionalString withMariaDB "echo '${mariadb}' >> $out/nix-support/depends"}
     ${lib.optionalString withPostgreSQL "echo '${postgresql}' >> $out/nix-support/depends"}
     ${lib.optionalString withSQLite "echo '${sqlite}' >> $out/nix-support/depends"}
  '';
}
