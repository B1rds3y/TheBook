#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: ./scripts/generate_app_icons.sh <path-to-source-image>"
  echo
  echo "Example:"
  echo "  ./scripts/generate_app_icons.sh assets/branding/logo.jpg"
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

SOURCE_IMAGE="$1"

if [[ ! -f "$SOURCE_IMAGE" ]]; then
  echo "Error: source image not found: $SOURCE_IMAGE"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORK_DIR="$PROJECT_ROOT/.tmp/icon_gen"
mkdir -p "$WORK_DIR"

TEMP_PNG="$WORK_DIR/source_icon.png"
CONFIG_FILE="$WORK_DIR/flutter_launcher_icons.yaml"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

SOURCE_EXT="${SOURCE_IMAGE##*.}"
SOURCE_EXT_LOWER="$(echo "$SOURCE_EXT" | tr '[:upper:]' '[:lower:]')"

if [[ "$SOURCE_EXT_LOWER" == "png" ]]; then
  cp "$SOURCE_IMAGE" "$TEMP_PNG"
else
  if command -v sips >/dev/null 2>&1; then
    sips -s format png "$SOURCE_IMAGE" --out "$TEMP_PNG" >/dev/null
  elif command -v magick >/dev/null 2>&1; then
    magick "$SOURCE_IMAGE" "$TEMP_PNG"
  elif command -v convert >/dev/null 2>&1; then
    convert "$SOURCE_IMAGE" "$TEMP_PNG"
  else
    echo "Error: cannot convert non-PNG image. Install one of: sips, magick, convert."
    exit 1
  fi
fi

cat > "$CONFIG_FILE" <<EOF
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "$TEMP_PNG"
  min_sdk_android: 21
  remove_alpha_ios: true
  web:
    generate: true
    image_path: "$TEMP_PNG"
    background_color: "#ffffff"
    theme_color: "#ffffff"
  windows:
    generate: true
    image_path: "$TEMP_PNG"
    icon_size: 48
  macos:
    generate: true
    image_path: "$TEMP_PNG"
EOF

cd "$PROJECT_ROOT"
dart run flutter_launcher_icons -f "$CONFIG_FILE"

echo
echo "App icon sets generated successfully for Android, iOS, Web, Windows, and macOS."
