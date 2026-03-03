# SingWord Release Guide

## Build Commands

```bash
./scripts/refresh_wordbooks.sh
node scripts/verify_wordbooks.mjs
./gradlew :app:assembleDebug
./gradlew :app:assembleRelease
./scripts/build_signed_release.sh
```

Release artifacts:

`app/build/outputs/apk/release/app-release-unsigned.apk`
`app/build/outputs/apk/release/app-release.apk` (installable, signed by script)

`build_signed_release.sh` will run `node scripts/verify_wordbooks.mjs` first when Node is available.

## Signing (local only)

1. `build_signed_release.sh` priority order:
   - Use release keystore from local env/properties.
   - Fallback to `~/.android/debug.keystore` for local install verification.
2. Configure release signing (do not commit secrets):
   - env vars: `RELEASE_STORE_FILE`, `RELEASE_STORE_PASSWORD`, `RELEASE_KEY_ALIAS`, `RELEASE_KEY_PASSWORD`
   - or `local.properties` keys: `release.storeFile`, `release.storePassword`, `release.keyAlias`, `release.keyPassword`
3. Script output includes SHA256 and signing mode for traceability.

## Current Known Limits

1. Genius fallback is a reserved skeleton and is disabled by default.
2. Requested book sources are partially available; details are in `data/sources/BOOK_DOWNLOAD_ATTEMPTS.md`.
3. No account/login/cloud sync in v1.

## Data Sources

1. Lyrics primary source: `lrclib.net`.
2. Wordbook source: bundled assets under `app/src/main/assets/wordbooks/`.
