#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EXAMPLE_APP_DIR="$ROOT_DIR/example-app"
PACKAGE_NAME="enroll-capacitor"
VERSION="${1:-latest}"

echo "==> Switching example app to published package"
echo "Package: $PACKAGE_NAME"
echo "Version: $VERSION"

cd "$EXAMPLE_APP_DIR"

npm pkg set "dependencies.$PACKAGE_NAME=$VERSION"
npm install

echo
echo "==> Example app now uses published package:"
echo "    $PACKAGE_NAME@$VERSION"
echo
echo "Next steps:"
echo "  cd $EXAMPLE_APP_DIR"
echo "  npm run build"
echo "  npx cap sync"
echo "  ../scripts/run-example-android.sh"
echo "  ../scripts/run-example-ios.sh"
