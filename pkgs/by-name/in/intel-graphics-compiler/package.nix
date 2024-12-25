{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  cmake,
  runCommandLocal,
  bison,
  flex,
  intel-compute-runtime,
  llvmPackages_14,
  opencl-clang,
  python3,
  spirv-tools,
  spirv-headers,
  spirv-llvm-translator,

  buildWithPatches ? true,
}:

let
  vc_intrinsics_src = fetchFromGitHub {
    owner = "intel";
    repo = "vc-intrinsics";
    rev = "v0.20.1";
    hash = "sha256-TnNhdGc6LZduQFiOMi23RDtyi6d/MLz03owOo/B2QnM=";
  };

  inherit (llvmPackages_14) lld llvm;
  inherit (if buildWithPatches then opencl-clang else llvmPackages_14) clang libclang;
  spirv-llvm-translator' = spirv-llvm-translator.override { inherit llvm; };
in

stdenv.mkDerivation rec {
  pname = "intel-graphics-compiler";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-graphics-compiler";
    tag = "v${version}";
    hash = "sha256-U1z5ORsCBJUCeVPowuCRbaEmuCAOtd1JFuVFnWe9xEI=";
  };

  postPatch = ''
    substituteInPlace IGC/AdaptorOCL/igc-opencl.pc.in \
      --replace-fail '/@CMAKE_INSTALL_INCLUDEDIR@' "/include" \
      --replace-fail '/@CMAKE_INSTALL_LIBDIR@' "/lib"

    chmod +x IGC/Scripts/igc_create_linker_script.sh
    patchShebangs --build IGC/Scripts/igc_create_linker_script.sh
  '';

  nativeBuildInputs = [
    bash
    bison
    cmake
    flex
    (python3.withPackages (
      ps: with ps; [
        mako
        pyyaml
      ]
    ))
  ];

  buildInputs = [
    lld
    llvm
    spirv-headers
    spirv-llvm-translator'
    spirv-tools
  ];

  strictDeps = true;

  # testing is done via intel-compute-runtime
  doCheck = false;

  # Handholding the braindead build script
  # cmake requires an absolute path
  prebuilds = runCommandLocal "igc-cclang-prebuilds" { } ''
    mkdir $out
    ln -s ${clang}/bin/clang $out/
    ln -s ${opencl-clang}/lib/* $out/
    ln -s ${lib.getLib libclang}/lib/clang/${lib.getVersion clang}/include/opencl-c.h $out/
    ln -s ${lib.getLib libclang}/lib/clang/${lib.getVersion clang}/include/opencl-c-base.h $out/
  '';

  cmakeFlags = [
    "-DVC_INTRINSICS_SRC=${vc_intrinsics_src}"
    "-DCCLANG_BUILD_PREBUILDS=ON"
    "-DCCLANG_BUILD_PREBUILDS_DIR=${prebuilds}"
    "-DIGC_OPTION__SPIRV_TOOLS_MODE=Prebuilds"
    "-DIGC_OPTION__VC_INTRINSICS_MODE=Source"
    "-Wno-dev"
  ];

  passthru.tests = {
    inherit intel-compute-runtime;
  };

  meta = with lib; {
    description = "LLVM-based compiler for OpenCL targeting Intel Gen graphics hardware";
    homepage = "https://github.com/intel/intel-graphics-compiler";
    changelog = "https://github.com/intel/intel-graphics-compiler/releases/tag/${src.tag}";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
