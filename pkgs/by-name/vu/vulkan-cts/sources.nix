# Autogenerated from vk-cts-sources.py
{ fetchurl, fetchFromGitHub }:
rec {
  amber = fetchFromGitHub {
    owner = "google";
    repo = "amber";
    rev = "57ba1ca211b6f4890c013dcf42cb16069ae916dd";
    hash = "sha256-mV9Eb+4rWDLAYCwyhAY42uuc8WqWwoOvT/Q8ov/2ISA=";
  };

  glslang = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "glslang";
    rev = "963588074b26326ff0426c8953c1235213309bdb";
    hash = "sha256-HLmTUILBohdM99H8UTyuzo1rTVKONkfCpniVWcvE2W8=";
  };

  jsoncpp = fetchFromGitHub {
    owner = "open-source-parsers";
    repo = "jsoncpp";
    rev = "9059f5cad030ba11d37818847443a53918c327b1";
    hash = "sha256-m0tz8w8HbtDitx3Qkn3Rxj/XhASiJVkThdeBxIwv3WI=";
  };

  nvidia-video-samples = fetchFromGitHub {
    owner = "Igalia";
    repo = "vk_video_samples";
    rev = "45fe88b456c683120138f052ea81f0a958ff3ec4";
    hash = "sha256-U5IoiRKXsdletVlnHVz8rgMEwDOZFAuld5Bzs0rvcR4=";
  };

  spirv-headers = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Headers";
    rev = "6d0784e9f1ab92c17eeea94821b2465c14a52be9";
    hash = "sha256-zAkAK3Dry7YM2xVs1Uwah2cwe8c8WJERLnsxghaMRiM=";
  };

  spirv-tools = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Tools";
    rev = "f06e0f3d2e5acfe4b14e714e4103dd1ccdb237e5";
    hash = "sha256-1t27QeNqGlevMC3BtN70rnPFgUcX/a811+UaUpMWe+o=";
  };

  video_generator = fetchFromGitHub {
    owner = "Igalia";
    repo = "video_generator";
    rev = "426300e12a5cc5d4676807039a1be237a2b68187";
    hash = "sha256-zdYYpX3hed7i5onY7c60LnM/e6PLa3VdrhXTV9oSlvg=";
  };

  vulkan-docs = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "112aee75d162412a4623e7d22a3de52e0233cbf5";
    hash = "sha256-6aeaQyNhI30Zr7ZrT7bgSWau24ADSrHnKyyhTjd4ELQ=";
  };

  vulkan-validationlayers = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-ValidationLayers";
    rev = "6ae58a2b17b2bcebdc5377995007391b85ffa10f";
    hash = "sha256-1Swwe7TsHinOXF1eNAdkDRzujTD/BK4HLxOVzd1tDQ8=";
  };

  vulkan-video-samples = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-Video-Samples";
    rev = "a22e0084e6f38a16dc0dcebb4c19a14651a6665b";
    hash = "sha256-LXCyFS/hRN4l+z5jNwT9G3MQ05tK+xqgz8uY8qje4jw=";
  };

  prePatch = ''
    mkdir -p external/amber external/glslang external/jsoncpp external/nvidia-video-samples external/spirv-headers external/spirv-tools external/video_generator external/vulkan-docs external/vulkan-validationlayers external/vulkan-video-samples

    cp -r ${amber} external/amber/src
    cp -r ${glslang} external/glslang/src
    cp -r ${jsoncpp} external/jsoncpp/src
    cp -r ${nvidia-video-samples} external/nvidia-video-samples/src
    cp -r ${spirv-headers} external/spirv-headers/src
    cp -r ${spirv-tools} external/spirv-tools/src
    cp -r ${video_generator} external/video_generator/src
    cp -r ${vulkan-docs} external/vulkan-docs/src
    cp -r ${vulkan-validationlayers} external/vulkan-validationlayers/src
    cp -r ${vulkan-video-samples} external/vulkan-video-samples/src
  '';
}
