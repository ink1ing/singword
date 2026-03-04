#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/android"
cd "$ROOT_DIR"

if [[ -z "${JAVA_HOME:-}" && -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]]; then
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

find_sdk_dir() {
  if [[ -n "${ANDROID_HOME:-}" ]]; then
    echo "$ANDROID_HOME"
    return
  fi
  if [[ -n "${ANDROID_SDK_ROOT:-}" ]]; then
    echo "$ANDROID_SDK_ROOT"
    return
  fi
  if [[ -f "$ANDROID_DIR/local.properties" ]]; then
    local sdk
    sdk="$(awk -F= '/^sdk\.dir=/{print $2}' "$ANDROID_DIR/local.properties" | sed 's#\\:#:#g' | tail -n1)"
    if [[ -n "$sdk" ]]; then
      echo "$sdk"
      return
    fi
  fi
  echo "$HOME/Library/Android/sdk"
}

find_apksigner() {
  local sdk_dir="$1"
  if command -v apksigner >/dev/null 2>&1; then
    command -v apksigner
    return
  fi
  local build_tools latest
  build_tools="$sdk_dir/build-tools"
  if [[ ! -d "$build_tools" ]]; then
    return 1
  fi
  latest="$(ls -1 "$build_tools" | sort -V | tail -n1)"
  if [[ -z "$latest" ]]; then
    return 1
  fi
  echo "$build_tools/$latest/apksigner"
}

read_local_prop() {
  local key="$1"
  if [[ -f "$ANDROID_DIR/local.properties" ]]; then
    awk -F= -v k="$key" '$1==k {print substr($0, index($0,$2))}' "$ANDROID_DIR/local.properties" | tail -n1
  fi
}

SDK_DIR="$(find_sdk_dir)"
APKSIGNER="$(find_apksigner "$SDK_DIR")"

if command -v node >/dev/null 2>&1; then
  node scripts/verify_wordbooks.mjs
else
  echo "node not found, skip wordbook verification"
fi

if [[ ! -x "$APKSIGNER" ]]; then
  echo "apksigner not found. SDK dir: $SDK_DIR"
  exit 1
fi

"$ANDROID_DIR/gradlew" -p "$ANDROID_DIR" :app:assembleRelease

UNSIGNED_APK="$ANDROID_DIR/app/build/outputs/apk/release/app-release-unsigned.apk"
SIGNED_APK="$ANDROID_DIR/app/build/outputs/apk/release/app-release.apk"

if [[ ! -f "$UNSIGNED_APK" ]]; then
  echo "Unsigned APK not found: $UNSIGNED_APK"
  exit 1
fi

rm -f "$SIGNED_APK"

RELEASE_STORE_FILE="${RELEASE_STORE_FILE:-$(read_local_prop release.storeFile)}"
RELEASE_STORE_PASSWORD="${RELEASE_STORE_PASSWORD:-$(read_local_prop release.storePassword)}"
RELEASE_KEY_ALIAS="${RELEASE_KEY_ALIAS:-$(read_local_prop release.keyAlias)}"
RELEASE_KEY_PASSWORD="${RELEASE_KEY_PASSWORD:-$(read_local_prop release.keyPassword)}"

if [[ -n "$RELEASE_STORE_FILE" && -n "$RELEASE_STORE_PASSWORD" && -n "$RELEASE_KEY_ALIAS" && -n "$RELEASE_KEY_PASSWORD" ]]; then
  if [[ ! -f "$RELEASE_STORE_FILE" ]]; then
    echo "release.storeFile does not exist: $RELEASE_STORE_FILE"
    exit 1
  fi

  "$APKSIGNER" sign \
    --ks "$RELEASE_STORE_FILE" \
    --ks-pass "pass:$RELEASE_STORE_PASSWORD" \
    --ks-key-alias "$RELEASE_KEY_ALIAS" \
    --key-pass "pass:$RELEASE_KEY_PASSWORD" \
    --out "$SIGNED_APK" \
    "$UNSIGNED_APK"
  SIGNING_MODE="release-keystore"
else
  DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
  if [[ ! -f "$DEBUG_KEYSTORE" ]]; then
    keytool -genkeypair -v \
      -keystore "$DEBUG_KEYSTORE" \
      -storepass android \
      -keypass android \
      -alias androiddebugkey \
      -keyalg RSA \
      -keysize 2048 \
      -validity 10000 \
      -dname "CN=Android Debug,O=Android,C=US" >/dev/null
  fi

  "$APKSIGNER" sign \
    --ks "$DEBUG_KEYSTORE" \
    --ks-pass pass:android \
    --ks-key-alias androiddebugkey \
    --key-pass pass:android \
    --out "$SIGNED_APK" \
    "$UNSIGNED_APK"
  SIGNING_MODE="debug-keystore"
fi

"$APKSIGNER" verify --print-certs "$SIGNED_APK" >/dev/null

SHA256="$(shasum -a 256 "$SIGNED_APK" | awk '{print $1}')"
echo "Signed APK: $SIGNED_APK"
echo "Signing mode: $SIGNING_MODE"
echo "SHA256: $SHA256"
