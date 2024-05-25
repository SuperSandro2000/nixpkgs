{
  mkKdeDerivation,
  qtwayland,
  qtmultimedia,
  opencv,
}:
mkKdeDerivation {
  pname = "spectacle";

  extraBuildInputs = [
    qtwayland
    qtmultimedia
    # https://invent.kde.org/graphics/spectacle/-/blob/master/CMakeLists.txt?ref_type=heads#L83
    ((opencv.override { runAccuracyTests = false; }).overrideAttrs ({ cmakeFlags, ... }: {
      cmakeFlags = cmakeFlags ++ [ "-DBUILD_LIST=core,imgproc" ];
    }))
  ];
  meta.mainProgram = "spectacle";
}
