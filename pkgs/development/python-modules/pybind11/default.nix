{
  stdenv,
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchFromGitHub,
  cmake,
  ninja,
  setuptools,
  boost,
  eigen,
  python,
  catch,
  numpy,
  pytestCheckHook,
  libxcrypt,
  makeSetupHook,
}:
let
  setupHook = makeSetupHook {
    name = "pybind11-setup-hook";
    substitutions = {
      out = placeholder "out";
      pythonInterpreter = python.pythonOnBuildForHost.interpreter;
      pythonIncludeDir = "${python}/include/${python.libPrefix}";
      pythonSitePackages = "${python}/${python.sitePackages}";
    };
  } ./setup-hook.sh;
in
buildPythonPackage rec {
  pname = "pybind11";
  version = "2.13.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pybind";
    repo = "pybind11";
    tag = "v${version}";
    hash = "sha256-SNLdtrOjaC3lGHN9MAqTf51U9EzNKQLyTMNPe0GcdrU=";
  };

  build-system = [
    cmake
    ninja
    setuptools
  ];

  buildInputs = lib.optionals (pythonOlder "3.9") [ libxcrypt ];
  propagatedNativeBuildInputs = [ setupHook ];

  dontUseCmakeBuildDir = true;

  # Don't build tests if not needed, read the doInstallCheck value at runtime
  preConfigure = ''
    if [ -n "$doInstallCheck" ]; then
      cmakeFlagsArray+=("-DBUILD_TESTING=ON")
    fi
  '';

  cmakeFlags = [
    "-DBoost_INCLUDE_DIR=${lib.getDev boost}/include"
    "-DEIGEN3_INCLUDE_DIR=${lib.getDev eigen}/include/eigen3"
  ]
  ++ lib.optionals (python.isPy3k && !stdenv.cc.isClang) [ "-DPYBIND11_CXX_STANDARD=-std=c++17" ];

  postBuild = ''
    # build tests
    make -j $NIX_BUILD_CORES
  '';

  postInstall = ''
    make install
    # Symlink the CMake-installed headers to the location expected by setuptools
    mkdir -p $out/include/${python.libPrefix}
    ln -sf $out/include/pybind11 $out/include/${python.libPrefix}/pybind11
  '';

  nativeCheckInputs = [
    catch
    numpy
    pytestCheckHook
  ];

  disabledTestPaths = [
    # require dependencies not available in nixpkgs
    "tests/test_embed/test_trampoline.py"
    "tests/test_embed/test_interpreter.py"
    # numpy changed __repr__ output of numpy dtypes
    "tests/test_numpy_dtypes.py"
    # no need to test internal packaging
    "tests/extra_python_package/test_files.py"
    # tests that try to parse setuptools stdout
    "tests/extra_setuptools/test_setuphelper.py"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # expects KeyError, gets RuntimeError
    # https://github.com/pybind/pybind11/issues/4243
    "test_cross_module_exception_translator"
  ];

  hardeningDisable = lib.optional stdenv.hostPlatform.isMusl "fortify";

  meta = with lib; {
    homepage = "https://github.com/pybind/pybind11";
    changelog = "https://github.com/pybind/pybind11/blob/${src.rev}/docs/changelog.rst";
    description = "Seamless operability between C++11 and Python";
    mainProgram = "pybind11-config";
    longDescription = ''
      Pybind11 is a lightweight header-only library that exposes
      C++ types in Python and vice versa, mainly to create Python
      bindings of existing C++ code.
    '';
    license = licenses.bsd3;
    maintainers = with maintainers; [
      yuriaisaka
      dotlambda
    ];
  };
}
