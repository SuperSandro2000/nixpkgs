{ lib
, fetchFromGitHub
, installShellFiles
, python3
}:

python3.pkgs.buildPythonApplication rec {
  pname = "git-sim";
  version = "0.2.9";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "initialcommit-com";
    repo = "git-sim";
    rev = "v${version}";
    hash = "sha256-Fkhcgt3RjsTOtM0YvxjdVh1ioigrQKJ8nRrZDOB/O/g=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "opencv-python-headless" ""
  '';

  propagatedBuildInputs = with python3.pkgs; [
    gitpython
    manim
    opencv4
    typer
    pydantic
    git-dummy
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/git-sim --show-completion $shell > git-sim.$shell
      installShellCompletion git-sim.$shell
    done
  '';

  meta = with lib; {
    description = "Visually simulate Git operations in your own repos with a single terminal command";
    homepage = "https://initialcommit.com/tools/git-sim";
    downloagPage = "https://github.com/initialcommit-com/git-sim";
    license = licenses.gpl2;
    maintainers = with maintainers; [ SuperSandro2000 mathiassven ];
  };
}
