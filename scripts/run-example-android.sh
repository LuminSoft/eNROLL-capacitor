#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EXAMPLE_APP_DIR="$ROOT_DIR/example-app"
ANDROID_DIR="$EXAMPLE_APP_DIR/android"
APK_PATH="$ANDROID_DIR/app/build/outputs/apk/debug/app-debug.apk"
APP_ID="com.luminsoft.EnrollTestingApp"
MAIN_ACTIVITY="com.example.plugin.MainActivity"
PLUGIN_PACKAGE_NAME="$(sed -n 's/  "name": "\(.*\)",/\1/p' "$ROOT_DIR/package.json" | head -n 1)"

ADB_BIN="${ADB_BIN:-adb}"
ADB_SERIAL="${ADB_SERIAL:-}"

adb_cmd() {
  if [[ -n "$ADB_SERIAL" ]]; then
    "$ADB_BIN" -s "$ADB_SERIAL" "$@"
  else
    "$ADB_BIN" "$@"
  fi
}

ensure_example_dependency() {
  local lockfile_path="$EXAMPLE_APP_DIR/package-lock.json"
  local module_path="$EXAMPLE_APP_DIR/node_modules/$PLUGIN_PACKAGE_NAME"

  if [[ -d "$module_path" ]] && grep -q "\"$PLUGIN_PACKAGE_NAME\": \"file:..\"" "$lockfile_path" 2>/dev/null; then
    return
  fi

  echo "==> Refreshing example app dependencies for $PLUGIN_PACKAGE_NAME"
  (
    cd "$EXAMPLE_APP_DIR"
    npm install
  )
}

select_device_if_needed() {
  if [[ -n "$ADB_SERIAL" ]]; then
    return
  fi

  connected_devices=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && connected_devices+=("$line")
  done < <(adb_cmd devices | awk 'NR>1 && $2=="device" {print $1}')

  if [[ ${#connected_devices[@]} -eq 0 ]]; then
    echo "No connected Android devices or emulators found." >&2
    exit 1
  fi

  if [[ ${#connected_devices[@]} -eq 1 ]]; then
    ADB_SERIAL="${connected_devices[0]}"
    echo "==> Using detected device: $ADB_SERIAL"
    return
  fi

  echo "==> Multiple Android devices detected. Please choose one:"
  select chosen_device in "${connected_devices[@]}"; do
    if [[ -n "${chosen_device:-}" ]]; then
      ADB_SERIAL="$chosen_device"
      echo "==> Selected device: $ADB_SERIAL"
      break
    fi
    echo "Invalid selection. Try again."
  done
}

echo "==> Building Capacitor plugin"
cd "$ROOT_DIR"
npm run build

ensure_example_dependency

echo "==> Building example app web assets"
cd "$EXAMPLE_APP_DIR"
npm run build

echo "==> Syncing Android Capacitor project"
npx cap sync android

echo "==> Assembling Android debug APK"
cd "$ANDROID_DIR"
./gradlew assembleDebug

if [[ ! -f "$APK_PATH" ]]; then
  echo "APK not found at: $APK_PATH" >&2
  exit 1
fi

echo "==> Checking connected Android devices"
adb_cmd devices
select_device_if_needed

echo "==> Installing APK"
adb_cmd install -r "$APK_PATH"

echo "==> Launching app"
adb_cmd shell am start -n "$APP_ID/$MAIN_ACTIVITY"

echo "==> Done"
if [[ -n "$ADB_SERIAL" ]]; then
  echo "Target device: $ADB_SERIAL"
fi
