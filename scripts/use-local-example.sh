#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EXAMPLE_APP_DIR="$ROOT_DIR/example-app"
PACKAGE_NAME="enroll-capacitor"

echo "==> Switching example app back to local package"

cd "$EXAMPLE_APP_DIR"

npm pkg set "dependencies.$PACKAGE_NAME=file:.."
npm install

echo
echo "==> Example app now uses local workspace package:"
echo "    $PACKAGE_NAME -> file:.."
