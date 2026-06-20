{
  lib,
  buildPythonPackage,
  fetchPypi,
  librosa,
  numpy,
  setuptools,
  torch,
}:

buildPythonPackage rec {
  pname = "torchlibrosa";
  version = "0.1.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Yqi+7fnJtBQaBiNN8/ECKfe6huZ2eMzuAkiexO8EQCg=";
  };

  build-system = [ setuptools ];

  buildInputs = [ torch ];

  dependencies = [
    librosa
    numpy
    torch.out
  ];

  # Project has no tests.
  # In order to make pythonImportsCheck work, NUMBA_CACHE_DIR env var need to
  # be set to a writable dir (https://github.com/numba/numba/issues/4032#issuecomment-488102702).
  # pythonImportsCheck has no pre* hook, use checkPhase to workaround that.
  checkPhase = ''
    export NUMBA_CACHE_DIR="$(mktemp -d)"
  '';
  pythonImportsCheck = [ "torchlibrosa" ];

  meta = {
    description = "PyTorch implemention of part of librosa functions";
    homepage = "https://github.com/qiuqiangkong/torchlibrosa";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
  };
}
