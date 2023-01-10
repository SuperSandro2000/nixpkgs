{
  # An attrset describing each platform configuration. All values are extract
  # from the GraalVM releases available on
  # https://github.com/graalvm/graalvm-ce-builds/releases
  # Example:
  # config = {
  #   x86_64-linux = {
  #     # List of products that will be included in the GraalVM derivation
  #     # See `with{NativeImage,Ruby,Python,WASM,*}Svm` variables for the
  #     # available values
  #     products = [ "graalvm-ce" "native-image-installable-svm" ];
  #     # GraalVM arch, not to be confused with the nix platform
  #     arch = "linux-amd64";
  #     # GraalVM version
  #     version = "22.0.0.2";
  #   };
  # }
  config
  # GraalVM version that will be used unless overridden by `config.<platform>.version`
, defaultVersion
  # Java version used by GraalVM
, javaVersion
  # Platforms were GraalVM will be allowed to build (i.e. `meta.platforms`)
, platforms ? builtins.attrNames config
  # If set to true, update script will (re-)generate the sources file even if
  # there are no updates available
, forceUpdate ? true
  # Path for the sources file that will be used
  # See `update.nix` file for a description on how this file works
, sourcesPath ? ./. + "/graalvm${javaVersion}-ce-sources.json"
  # Use musl instead of glibc to allow true static builds in GraalVM's
  # Native Image (i.e.: `--static --libc=musl`). This will cause glibc static
  # builds to fail, so it should be used with care
, useMusl ? false
}@args:

{ stdenv
, lib
, autoPatchelfHook
, callPackage
, bash
, fetchurl
, makeWrapper
, setJavaClassPath
, wrapBintoolsWith
, wrapCCWith
, writeShellScriptBin
  # minimum dependencies
, alsa-lib
, fontconfig
, Foundation
, freetype
, glibc
, glibcLocales
, graalvmCEPackages
, libgcc
, openssl_1_1
, perl
, unzip
, xorg
, zlib
  # runtime dependencies
, binutils
, cups
, musl
  # runtime dependencies for GTK+ Look and Feel
, gtkSupport ? stdenv.isLinux
, cairo
, glib
  # updateScript deps
, gnused
, gtk3
, jq
, writeShellScript

, which
}:

assert useMusl -> stdenv.isLinux;

let
  platform = config.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  version = platform.version or defaultVersion;
  name = "graalvm${javaVersion}-ce";
  sources = builtins.fromJSON (builtins.readFile sourcesPath);

  runtimeLibraryPath = lib.makeLibraryPath ([ cups ]
    ++ lib.optionals gtkSupport [ cairo glib gtk3 ]);

  runtimeDependencies = lib.makeBinPath ([
    binutils
    stdenv.cc
  ] ++ lib.optionals useMusl [
    (lib.getDev musl)
    # GraalVM 21.3.0+ expects musl-gcc as <system>-musl-gcc
    (writeShellScriptBin "${stdenv.hostPlatform.system}-musl-gcc" ''${lib.getDev musl}/bin/musl-gcc "$@"'')
  ]);

  withGraalVm = builtins.elem "graalvm-ce" platform.products;
  withNativeImageSvm = builtins.elem "native-image-installable-svm" platform.products;
  withLlvmSvm = builtins.elem "llvm-installable-svm" platform.products;
  withRubySvm = builtins.elem "ruby-installable-svm" platform.products;
  withPythonSvm = builtins.elem "python-installable-svm" platform.products;
  withToolChainLlvm = builtins.elem "llvm-toolchain-installable" platform.products;
  withWasmSvm = builtins.elem "wasm-installable-svm" platform.products;

  llvm-cc = wrapCCWith rec {
    bintools = wrapBintoolsWith { bintools = cc; };
    cc = (graalvmCEPackages.mkGraal (lib.recursiveUpdate args {
      config = {
        pname = name + "-llvm";
        ${stdenv.hostPlatform.system} = {
          products = [ "llvm-installable-svm" "llvm-toolchain-installable" ];
        };
      };
    }));
  };

  # graalLlvmToolchain = wrapCCWith {
  #   cc = (graalvmCEPackages.mkGraal (lib.recursiveUpdate args {
  #     config = {
  #       pname = name + "-llvm-toolchain";
  #       ${stdenv.hostPlatform.system} = {
  #         products = [ "llvm-toolchain-installable" ];
  #       };
  #     };
  #   })).override { gtkSupport = false; };
  # };

  graalvmXXX-ce = stdenv.mkDerivation rec {
    inherit version;
    pname = config.pname or name;

    srcs = map fetchurl (
      # filter sources that are in products
      map (product: sources.${platform.arch}."${product}|java${javaVersion}|${version}") platform.products
    );

    outputs = [ "out" ]
      # error: cycle detected in the references of output 'lib' from output 'out'
      ++ lib.optional (!withLlvmSvm) "lib";

    # manually done when ruby is used in an earlier phase
    # to be able to execute ruby to re-compile the openssl gem
    dontAutoPatchelf = withRubySvm;

    nativeBuildInputs = [ unzip perl makeWrapper which ]
      ++ lib.optional stdenv.isLinux autoPatchelfHook
      ++ lib.optionals withRubySvm [ glibcLocales llvm-cc ];

    buildInputs = lib.optionals stdenv.isLinux [
      alsa-lib # libasound.so wanted by lib/libjsound.so
      fontconfig
      freetype
      stdenv.cc.cc.lib # libstdc++.so.6
      xorg.libX11
      xorg.libXext
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
      zlib
    ] ++ lib.optionals withRubySvm [
      llvm-cc.cc # contains libgraalvm-llvm.so.1
      # TODO: assert/check this
      # llvmPackages_14.libcxx 
      # llvmPackages_14.libcxxabi
    ];

    unpackPhase = ''
      unpack_jar() {
        jar=$1
        unzip -q -o $jar -d build
        perl -ne 'use File::Path qw(make_path);
                  use File::Basename qw(dirname);
                  if (/^(.+) = (.+)$/) {
                    make_path dirname("build/$1");
                    system "ln -s $2 build/$1";
                  }' build/META-INF/symlinks
        perl -ne 'if (/^(.+) = ([r-])([w-])([x-])([r-])([w-])([x-])([r-])([w-])([x-])$/) {
            my $mode = ($2 eq 'r' ? 0400 : 0) + ($3 eq 'w' ? 0200 : 0) + ($4  eq 'x' ? 0100 : 0) +
                       ($5 eq 'r' ? 0040 : 0) + ($6 eq 'w' ? 0020 : 0) + ($7  eq 'x' ? 0010 : 0) +
                       ($8 eq 'r' ? 0004 : 0) + ($9 eq 'w' ? 0002 : 0) + ($10 eq 'x' ? 0001 : 0);
            chmod $mode, "build/$1";
          }' build/META-INF/permissions
        rm -rf build/META-INF
      }

      mkdir build/
      arr=($srcs)
    '' + lib.optionalString withGraalVm ''
      # The tarball on Linux has the following directory structure:
      #
      #   graalvm-ce-java11-20.3.0/*
      #
      # while on Darwin it looks like this:
      #
      #   graalvm-ce-java11-20.3.0/Contents/Home/*
      #
      # We therefor use --strip-components=1 vs 3 depending on the platform.
      tar xf ''${arr[0]} -C build --strip-components=${if stdenv.isLinux then "1" else "3"}

      # Sanity check
      if [ ! -d build/bin ]; then
         echo "The bin is directory missing after extracting the graalvm"
         echo "tarball, please compare the directory structure of the"
         echo "tarball with what happens in the unpackPhase (in particular"
         echo "with regards to the --strip-components flag)."
         exit 1
      fi
    '' + ''
      for jar in "''${arr[@]${lib.optionalString withGraalVm ":1"}}"; do
        unpack_jar "$jar"
      done
    '';

    buildPhase = lib.optionalString withRubySvm ''
      # requires openssl_1_0 but we rebuild it anyway
      rm build/languages/ruby/lib/mri/openssl.so

      autoPatchelf build/

      # truffleruby searches for librubyvm.so relative to ld-linux
      LD_LIBRARY_PATH=build/languages/ruby/lib build/languages/ruby/bin/truffleruby --version

      # substituteInPlace build/languages/ruby/lib/truffle/rbconfig.rb \
      #   --replace "cppflags = '" "cppflags = '-I${glibc.dev}/include"
        # --replace "ldflags = '" "ldflags = '-L${glibc.out}/lib -B${glibc.out}/lib -B${libgcc}/lib"

      # substituteInPlace build/languages/ruby/lib/mri/mkmf.rb \
      #   --replace 'CC) #{' 'CC) -fuse-ld=ld.lld #{'

      # dirty hack but the best I could come up with after hours
      # the clang used checks -fuse-ld to be exactly like '-fuse-ld=ld.lld' on linux
      # if it is anything else including ld.lld as an absolute path if will fail
      # with an error that -fuse-ld is unsupported which is infact wrong
      # https://github.com/oracle/graal/blob/vm-ce-22.3.0/sulong/projects/com.oracle.truffle.llvm.toolchain.launchers/src/com/oracle/truffle/llvm/toolchain/launchers/common/ClangLikeBase.java#L139-L143
      # makeWrapper .graalvm-native-clang-wrapped build/languages/llvm/native/bin/graalvm-native-clang \
      #   --add-flags "-fuse-ld=ld.lld"
      mv build/languages/llvm/native/bin/{graalvm-native-clang,.graalvm-native-clang-wrapped}
      echo "#!${bash} -e
      exec -a "$0" .graalvm-native-clang-wrapped -fuse-ld=ld.lld "$@"
      " > build/languages/llvm/native/bin/graalvm-native-clang
      chmod +x build/languages/llvm/native/bin/graalvm-native-clang

      ln -s ${llvm-cc.cc}/ build/lib/llvm
      for f in ${llvm-cc.cc}/bin/*; do
        ln -fs $f build/lib/llvm/bin/$(basename $f)
      done

      # realpath /nix/store/5xy0gbwbdf4vpd8kap4fl6nif3x4nm5r-graalvm17-ce-llvm-22.3.0/bin/clang
      # ldd /nix/store/5xy0gbwbdf4vpd8kap4fl6nif3x4nm5r-graalvm17-ce-llvm-22.3.0/languages/llvm/native/bin/.graalvm-native-clang-wrapped

      patchShebangs build/languages/ruby/lib/truffle/post_install_hook.sh

      export LANG=en_US.UTF-8
      CORES=$NIX_BUILD_CORES build/languages/ruby/lib/truffle/post_install_hook.sh
      rm build/lib/llvm
    '';

    installPhase = ''
      runHook preInstall

      cp -r build/. $out/

      # ensure that $lib/lib exists to avoid breaking builds
      mkdir -p "''${lib:-out}/lib"
      # jni.h expects jni_md.h to be in the header search path.
      ln -s $out/include/linux/*_md.h $out/include/

      # copy-paste openjdk's preFixup
      # Set JAVA_HOME automatically.
      mkdir -p $out/nix-support
      cat > $out/nix-support/setup-hook << EOF
        if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out; fi
      EOF
    '' + lib.optionalString (withNativeImageSvm && stdenv.isLinux) ''
      # provide libraries needed for static compilation
      ${if useMusl then
          ''for f in "${musl.stdenv.cc.cc}/lib/"* "${musl}/lib/"* "${zlib.static}/lib/"*; do''
        else
          ''for f in "${glibc}/lib/"* "${glibc.static}/lib/"* "${zlib.static}/lib/"*; do''
      }
        ln -s "$f" "$out/lib/svm/clibraries/${platform.arch}/$(basename $f)"
      done

      # add those libraries to $lib output too, so we can use them with
      # `native-image -H:CLibraryPath=''${lib.getLib graalvmXX-ce}/lib ...` and reduce
      # closure size by not depending on GraalVM $out (that is much bigger)
      # we always use glibc here, since musl is only supported for static compilation
      for f in "${glibc}/lib/"*; do
        ln -s "$f" "''${lib:-$out}/lib/$(basename $f)"
      done
    '' + lib.optionalString withLlvmSvm ''
      # wrapCC has hardcoded paths for /bin, /lib

      # colides with $out/lib/llvm/bin/lli later
      # rm $out/bin/lli

      for f in $out/languages/llvm/native/bin/*; do
        ln -s $f $out/bin/$(basename $f)
      done
      # wrapCC can only wrapp gcc or llvm/clang and we need llvm
      rm $out/bin/{gcc,g++}
      for f in $out/languages/llvm/native/lib/*; do
        ln -s $f $out/lib/$(basename $f)
      done

      # ln -s $out/languages/llvm/include $out/include
      # for f in $out/languages/llvm/lib/*; do
      #   ln -s $f $out/lib/$(basename $f)
      # done

      # for f in $out/lib/llvm/bin/*; do
      #   ln -s $f $out/bin/$(basename $f)
      # done
      # ln -s $out/lib/llvm/include $out/include
      # for f in $out/lib/llvm/lib/*; do
      #   ln -s $f $out/lib/$(basename $f)
      # done

      runHook postInstall
    '';

    preFixup = lib.optionalString stdenv.isLinux ''
      # Find all executables in any directory that contains '/bin/'
      for bin in $(find "$out" -executable -type f -wholename '*/bin/*'); do
        wrapProgram "$bin" \
          --prefix LD_LIBRARY_PATH : "${runtimeLibraryPath}" \
          --prefix PATH : "${runtimeDependencies}"
      done

      find "$out" -name libfontmanager.so -exec \
        patchelf --add-needed libfontconfig.so {} \;
    '';

    # $out/bin/native-image needs zlib to build native executables.
    propagatedBuildInputs = [ setJavaClassPath zlib ]
      # On Darwin native-image calls clang and it tries to include <Foundation/Foundation.h>
      ++ lib.optionals stdenv.isDarwin [ Foundation ];

    doInstallCheck = false;
    installCheckPhase = lib.optionalString withGraalVm ''
      echo ${lib.escapeShellArg ''
        public class HelloWorld {
          public static void main(String[] args) {
            System.out.println("Hello World");
          }
        }
      ''} > HelloWorld.java
      $out/bin/javac HelloWorld.java

      # run on JVM with Graal Compiler
      $out/bin/java -XX:+UnlockExperimentalVMOptions -XX:+EnableJVMCI -XX:+UseJVMCICompiler HelloWorld | fgrep 'Hello World'
    ''
    # --static flag doesn't work for darwin
    + lib.optionalString (withNativeImageSvm && stdenv.isLinux && !useMusl) ''
      echo "Ahead-Of-Time compilation"
      $out/bin/native-image -H:-CheckToolchain -H:+ReportExceptionStackTraces --no-server HelloWorld
      ./helloworld | fgrep 'Hello World'

      echo "Ahead-Of-Time compilation with --static"
      $out/bin/native-image --no-server --static HelloWorld
      ./helloworld | fgrep 'Hello World'
    ''
    # --static flag doesn't work for darwin
    + lib.optionalString (withNativeImageSvm && stdenv.isLinux && useMusl) ''
      echo "Ahead-Of-Time compilation with --static and --libc=musl"
      $out/bin/native-image --no-server --libc=musl --static HelloWorld
      ./helloworld | fgrep 'Hello World'
    ''
    + lib.optionalString withWasmSvm ''
      echo "Testing Jshell"
      echo '1 + 1' | $out/bin/jshell
    ''
    + lib.optionalString withPythonSvm ''
      echo "Testing GraalPython"
      $out/bin/graalpython -c 'print(1 + 1)'
      echo '1 + 1' | $out/bin/graalpython
    ''
    + lib.optionalString withRubySvm ''
      echo "Testing TruffleRuby"
      # Hide warnings about wrong locale
      export LANG=C
      export LC_ALL=C
      $out/bin/ruby -e 'puts(1 + 1)'
      echo '1 + 1' | $out/bin/irb

      [[ ruby -e 'puts(RUBY_VERSION)' = ${passthru.majMinTiny} ]]
    '';

    passthru = {
      inherit llvm-cc;
      inherit (platform) products;
      home = graalvmXXX-ce;
      updateScript = import ./update.nix {
        inherit config defaultVersion forceUpdate gnused jq lib name sourcesPath writeShellScript;
        graalVersion = version;
        javaVersion = "java${javaVersion}";
      };
    } // (let
      # TODO: assert/check this
      rubyVersion = callPackage ../../../interpreters/ruby/ruby-version.nix {} "3" "0" "3" "";
    in lib.optionalAttrs withRubySvm rec {
      inherit (rubyVersion) majMinTiny;
      rubyEngine = "jruby";
      gemPath = "lib/${rubyEngine}/gems/${rubyVersion.libDir}";
      libPath = "lib/${rubyEngine}/${rubyVersion.libDir}";
    });

    meta = with lib; {
      inherit platforms;
      homepage = "https://www.graalvm.org/";
      description = "High-Performance Polyglot VM";
      license = with licenses; [ upl gpl2Classpath bsd3 ];
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      mainProgram = "java";
      maintainers = with maintainers; [
        bandresen
        hlolli
        glittershark
        babariviere
        ericdallo
        thiagokokada
        SuperSandro2000 # TruffleRuby
      ];
    };
  };
in
graalvmXXX-ce
