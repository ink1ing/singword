#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/android"
MODE="${1:-device}"
TEST_CLASS="com.singword.app.acceptance.AcceptanceFlowTest"

if [[ -z "${JAVA_HOME:-}" ]]; then
  if [[ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]]; then
    export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
    export PATH="$JAVA_HOME/bin:$PATH"
  fi
fi

ADB="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}/platform-tools/adb"
if [[ ! -x "$ADB" ]]; then
  echo "adb not found at $ADB"
  exit 1
fi

if ! "$ADB" get-state >/dev/null 2>&1; then
  echo "No connected device/emulator."
  "$ADB" devices -l || true
  exit 1
fi

case "$MODE" in
  device|emulator)
    ;;
  *)
    echo "Usage: $0 [device|emulator]"
    exit 1
    ;;
esac

cd "$ROOT_DIR"

"$ANDROID_DIR/gradlew" -p "$ANDROID_DIR" :app:assembleDebug :app:assembleDebugAndroidTest

"$ADB" install -r "$ANDROID_DIR/app/build/outputs/apk/debug/app-debug.apk"
"$ADB" install -r "$ANDROID_DIR/app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk"

"$ADB" shell am instrument -w \
  -e class "$TEST_CLASS" \
  com.singword.app.test/androidx.test.runner.AndroidJUnitRunner
