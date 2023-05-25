{ lib
, clangStdenv
, fetchFromGitHub
, cmake
, runCommandLocal
, bison
, flex
, llvmPackages_11
, opencl-clang
, python3
, spirv-tools
, spirv-llvm-translator
, spirv-headers

, buildWithPatches ? false
}:

let
  # a build with c++11 is required otherwise linking fails with:
  #   undefined reference to `spvDecodeLiteralStringOperand[abi:cxx11](spv_parsed_instruction_t const&, unsigned short)'
  spirv-headers' = spirv-headers.overrideAttrs ({ cmakeFlags ? [ ], ... }: let
    version = "1.3.239.0";
  in {
    inherit version;

    cmakeFlags = cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=14"
    ];

    src = spirv-headers.src.override {
      rev = "sdk-${version}";
      hash = "sha256-bjiWGSmpEbydXtCLP8fRZfPBvdCzBoJxKXTx3BroQbg=";
    };
  });

  spirv-tools' = spirv-tools.overrideAttrs ({ cmakeFlags ? [ ], ... }: let
    version = "1.3.239.0";
  in {
    inherit version;

    cmakeFlags = cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=14"
    ];

    src = spirv-tools.src.override {
      rev = "sdk-${version}";
      hash = "sha256-xLYykbCHb6OH5wUSgheAfReXhxZtI3RqBJ+PxDZx58s=";
    };
  });

  spirv-llvm-translator' = (spirv-llvm-translator.override {
    inherit llvm;
    spirv-headers = spirv-headers';
    spirv-tools = spirv-tools';
  }).overrideAttrs ({ cmakeFlags ? [ ], ... }: {
    cmakeFlags = cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=14"
    ];
  });

  opencl-clang' = opencl-clang.override { spirv-llvm-translator = spirv-llvm-translator'; };

  vc_intrinsics_src = fetchFromGitHub {
    owner = "intel";
    repo = "vc-intrinsics";
    rev = "v0.12.3";
    sha256 = "sha256-3rhwWC8mCNxntmGhZ6kRCosHyzehjLl7WaLCubljcA0=";
  };

  llvmPkgs = llvmPackages_11 // lib.optionalAttrs buildWithPatches opencl-clang';

  inherit (llvmPackages_11) lld llvm;
  inherit (llvmPkgs) clang libclang;
in

clangStdenv.mkDerivation rec {
  pname = "intel-graphics-compiler";
  version = "1.0.13700.14";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-graphics-compiler";
    rev = "igc-${version}";
    sha256 = "sha256-592qlz4vsU3iTkxf5ulsbf4vyvuyzUgtvBFrnAgA5Cw=";
  };

  nativeBuildInputs = [ cmake bison flex python3 ];

  buildInputs = [ spirv-headers' spirv-tools' spirv-llvm-translator' llvm lld ];

  strictDeps = true;

  # testing is done via intel-compute-runtime
  doCheck = false;

  postPatch = ''
    substituteInPlace external/SPIRV-Tools/CMakeLists.txt \
      --replace '$'''{SPIRV-Tools_DIR}/../../..' \
                '${spirv-tools'}' \
      --replace 'SPIRV-Headers_INCLUDE_DIR "/usr/include"' \
                'SPIRV-Headers_INCLUDE_DIR "${spirv-headers'}/include"' \
      --replace 'set_target_properties(SPIRV-Tools' \
                'set_target_properties(SPIRV-Tools-shared' \
      --replace 'IGC_BUILD__PROJ__SPIRV-Tools SPIRV-Tools' \
                'IGC_BUILD__PROJ__SPIRV-Tools SPIRV-Tools-shared'
    substituteInPlace IGC/AdaptorOCL/igc-opencl.pc.in \
      --replace '/@CMAKE_INSTALL_INCLUDEDIR@' "/include" \
      --replace '/@CMAKE_INSTALL_LIBDIR@' "/lib"
  '';

  # Handholding the braindead build script
  # cmake requires an absolute path
  prebuilds = runCommandLocal "igc-cclang-prebuilds" { } ''
    mkdir $out
    ln -s ${clang}/bin/clang $out/
    ln -s clang $out/clang-${lib.versions.major (lib.getVersion clang)}
    ln -s ${opencl-clang'}/lib/* $out/
    ln -s ${lib.getLib libclang}/lib/clang/${lib.getVersion clang}/include/opencl-c.h $out/
    ln -s ${lib.getLib libclang}/lib/clang/${lib.getVersion clang}/include/opencl-c-base.h $out/
  '';

  cmakeFlags = [
    "-Wno-dev"
    "-DVC_INTRINSICS_SRC=${vc_intrinsics_src}"
    "-DIGC_OPTION__SPIRV_TOOLS_MODE=Prebuilds"
    "-DCCLANG_BUILD_PREBUILDS=ON"
    "-DCCLANG_BUILD_PREBUILDS_DIR=${prebuilds}"
    "-DIGC_PREFERRED_LLVM_VERSION=${lib.getVersion llvm}"
    "-DCMAKE_CXX_STANDARD=14"
  ];

  passthru = { a = spirv-tools'; };

  meta = with lib; {
    description = "LLVM-based compiler for OpenCL targeting Intel Gen graphics hardware";
    homepage = "https://github.com/intel/intel-graphics-compiler";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
