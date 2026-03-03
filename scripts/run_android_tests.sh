#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${1:-device}"

if [[ -z "${JAVA_HOME:-}" ]]; then
  if [[ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]]; then
    export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
    export PATH="$JAVA_HOME/bin:$PATH"
  fi
fi

ADB="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
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
  device)
    INSTRUMENT_ARGS=("-e" "notAnnotation" "com.singword.app.test.EmulatorOnly")
    ;;
  emulator)
    INSTRUMENT_ARGS=()
    ;;
  *)
    echo "Usage: $0 [device|emulator]"
    exit 1
    ;;
esac

cd "$ROOT_DIR"

./gradlew :app:assembleDebug :app:assembleDebugAndroidTest

"$ADB" install -r app/build/outputs/apk/debug/app-debug.apk
"$ADB" install -r app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk

"$ADB" shell am instrument -w "${INSTRUMENT_ARGS[@]}" com.singword.app.test/androidx.test.runner.AndroidJUnitRunner
