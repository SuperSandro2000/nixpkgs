# shellcheck shell=bash
# shellcheck disable=SC2016
fixupOutputHooks+=('if [ -z "${dontCompressWebAssets-}" ]; then compressWebAssets "$prefix"; fi')

compressWebAssets() {
  echo "Compressing web assets..."
  time find -L "$1" -type f -regextype posix-extended -iregex ".*\.(css|eot|html?|js|js.map|otf|scss|svg|ttf|txt|xml)" -not -iregex ".*(\/apps\/.*\/l10n\/).*" \
    -exec echo 'Compressing {} ...' \; \
    -exec brotli --keep --no-copy-stat '{}' \; \
    -exec zopfli '{}' \;
}

