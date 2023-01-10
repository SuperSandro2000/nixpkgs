{ callPackage, config, lib, Foundation }:
/*
  Add new graal versions and products here and then see update.nix on how to
  generate the sources.
*/

let
  mkGraal = opts: callPackage (import ./mkGraal.nix opts) {
    inherit Foundation;
  };

  /*
    Looks a bit ugly but makes version update in the update script using sed
    much easier

    Don't change these values! They will be updated by the update script, see ./update.nix.
  */
  graalvm11-ce-release-version = "22.3.0";
  graalvm17-ce-release-version = "22.3.0";

  genConfig = products: {
    x86_64-darwin = {
      inherit products;
      arch = "darwin-amd64";
    };
    x86_64-linux = {
      inherit products;
      arch = "linux-amd64";
    };
    aarch64-darwin = {
      inherit products;
      arch = "darwin-aarch64";
    };
    aarch64-linux = {
      inherit products;
      arch = "linux-aarch64";
    };
  };
in
let self = {
  inherit mkGraal;

  graalvm11 = mkGraal {
    config = genConfig [ "graalvm-ce" "native-image-installable-svm" ];
    defaultVersion = graalvm11-ce-release-version;
    javaVersion = "11";
  };

  graalvm17 = mkGraal {
    config = genConfig [ "graalvm-ce" "native-image-installable-svm" ];
    defaultVersion = graalvm17-ce-release-version;
    javaVersion = "17";
  };

  truffleruby17 = mkGraal {
    # ruby-installable-svm requires llvm-installable-svm to run
    config = genConfig [ "llvm-installable-svm" "llvm-toolchain-installable" "ruby-installable-svm" ];
    defaultVersion = graalvm17-ce-release-version;
    javaVersion = "17";
  };
}; in self // lib.optionalAttrs config.allowAliases {
  # deprecated or renamed packages
  graalvm11-ce = self.graalvm11;
  graalvm17-ce = self.graalvm17;
}
