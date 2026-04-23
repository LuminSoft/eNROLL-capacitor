#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EXAMPLE_APP_DIR="$ROOT_DIR/example-app"
IOS_DIR="$EXAMPLE_APP_DIR/ios/App"
WORKSPACE_PATH="$IOS_DIR/App.xcworkspace"
SCHEME="App"
CONFIGURATION="${CONFIGURATION:-Debug}"
DEVICE_ID="${DEVICE_ID:-}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/.derived-data/run-example-ios}"
PLUGIN_PACKAGE_NAME="$(sed -n 's/  "name": "\(.*\)",/\1/p' "$ROOT_DIR/package.json" | head -n 1)"

list_connected_ios_devices() {
  xcrun xctrace list devices | awk '
    /^== Devices ==/ { in_devices=1; next }
    /^== Devices Offline ==/ { in_devices=0 }
    /^== Simulators ==/ { in_devices=0 }
    in_devices && /\(/ {
      line=$0
      sub(/^[ \t]+/, "", line)
      if (line !~ /MacBook/ && line !~ /Simulator/) {
        print line
      }
    }
  '
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
  if [[ -n "$DEVICE_ID" ]]; then
    return
  fi

  device_lines=()
  device_ids=()

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    device_lines+=("$line")
    device_ids+=("$(printf '%s\n' "$line" | sed -n 's/.*(\([A-F0-9-]\{10,\}\)).*/\1/p')")
  done < <(list_connected_ios_devices)

  if [[ ${#device_ids[@]} -eq 0 ]]; then
    echo "No connected iPhone/iPad devices found." >&2
    exit 1
  fi

  if [[ ${#device_ids[@]} -eq 1 ]]; then
    DEVICE_ID="${device_ids[0]}"
    echo "==> Using detected iOS device: ${device_lines[0]}"
    return
  fi

  echo "==> Multiple iOS devices detected. Please choose one:"
  select chosen_line in "${device_lines[@]}"; do
    if [[ -n "${chosen_line:-}" ]]; then
      DEVICE_ID="$(printf '%s\n' "$chosen_line" | sed -n 's/.*(\([A-F0-9-]\{10,\}\)).*/\1/p')"
      echo "==> Selected device: $chosen_line"
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

echo "==> Syncing iOS Capacitor project"
npx cap sync ios

echo "==> Checking connected iOS devices"
list_connected_ios_devices
select_device_if_needed

echo "==> Building iOS app for device $DEVICE_ID"
xcodebuild \
  -workspace "$WORKSPACE_PATH" \
  -scheme "$SCHEME" \
  -destination "id=$DEVICE_ID" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build

APP_PATH="$DERIVED_DATA_PATH/Build/Products/${CONFIGURATION}-iphoneos/App.app"

if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  echo "Built App.app not found in DerivedData." >&2
  exit 1
fi

echo "==> Installing app"
xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH"

BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$APP_PATH/Info.plist")"

if [[ -z "$BUNDLE_ID" ]]; then
  echo "Unable to read bundle identifier from $APP_PATH/Info.plist" >&2
  exit 1
fi

echo "==> Launching app"
xcrun devicectl device process launch --device "$DEVICE_ID" "$BUNDLE_ID"

echo "==> Done"
echo "Device ID: $DEVICE_ID"
echo "Bundle ID: $BUNDLE_ID"
