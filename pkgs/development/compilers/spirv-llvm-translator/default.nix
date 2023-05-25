{ lib, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, lit
, llvm
, spirv-headers
, spirv-tools
}:

let
  llvmMajor = lib.versions.major llvm.version;
  isROCm = lib.hasPrefix "rocm" llvm.pname;

  # ROCm will always be at the latest version
  branch =
    if llvmMajor == "15" || isROCm then rec {
      version = "15.0.0";
      rev = "v${version}";
      hash = "sha256-OsDohXRxovtEXaWiRGp8gJ0dXmoALyO+ZimeSO8aPVI=";
    } else if llvmMajor == "14" then rec{
      version = "14.0.0";
      rev = "v${version}";
      hash = "sha256-BhNAApgZ/w/92XjpoDY6ZEIhSTwgJ4D3/EfNvPmNM2o=";
    } else if llvmMajor == "11" then {
      # https://github.com/KhronosGroup/SPIRV-LLVM-Translator/commits/llvm_release_110
      version = "unstable-2023-02-20";
      rev = "b23efa4f0400f8ee10f1db0cc9ff2e081b581ca1";
      hash = "sha256-TOPn2FWaRpa00fNnm1s/BY28tk5Wj3EUXRSc5/KUbPc=";
    } else throw "Incompatible LLVM version.";
in
stdenv.mkDerivation {
  pname = "SPIRV-LLVM-Translator";
  inherit (branch) version;

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-LLVM-Translator";
    inherit (branch) rev hash;
  };

  nativeBuildInputs = [ pkg-config cmake spirv-tools ]
    ++ (if isROCm then [ llvm ] else [ llvm.dev ]);

  buildInputs = [ spirv-headers ]
    ++ lib.optionals (!isROCm) [ llvm ];

  nativeCheckInputs = [ lit ];

  cmakeFlags = [
    "-DLLVM_INCLUDE_TESTS=ON"
    "-DLLVM_DIR=${(if isROCm then llvm else llvm.dev)}"
    "-DBUILD_SHARED_LIBS=YES"
    "-DLLVM_SPIRV_BUILD_EXTERNAL=YES"
    # RPATH of binary /nix/store/.../bin/llvm-spirv contains a forbidden reference to /build/
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ] ++ lib.optionals (llvmMajor != "11") [ "-DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=${spirv-headers.src}" ];

  # FIXME: CMake tries to run "/llvm-lit" which of course doesn't exist
  doCheck = false;

  makeFlags = [ "all" "llvm-spirv" ];

  postInstall = ''
    install -D tools/llvm-spirv/llvm-spirv $out/bin/llvm-spirv
  '';

  meta = with lib; {
    homepage    = "https://github.com/KhronosGroup/SPIRV-LLVM-Translator";
    description = "A tool and a library for bi-directional translation between SPIR-V and LLVM IR";
    license     = licenses.ncsa;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ gloaming ];
  };
}
