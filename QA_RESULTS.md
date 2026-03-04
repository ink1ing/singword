# SingWord QA Results (2026-03-03)

## Environment

- Device: `24090RA29G` (Android 14)
- Host: macOS + Android Studio JBR (`/Applications/Android Studio.app/Contents/jbr/Contents/Home`)
- Project path: `/Users/silas/Desktop/singword`

## Wordbook Assets

- `cet4.json`: 2675
- `cet6.json`: 2219
- `ielts.json`: 1922
- `toefl.json`: 9971

Release APK packed assets verified:
- `assets/wordbooks/cet4.json`
- `assets/wordbooks/cet6.json`
- `assets/wordbooks/ielts.json`
- `assets/wordbooks/toefl.json`
- `assets/wordbooks/manifest.json`

`invalid.json` is not shipped in release APK.

Rebuild command verified:
- `node scripts/import_wordbooks_from_sources.mjs` (rebuilds `cet4/cet6/ielts/toefl` + `manifest`)
- `node scripts/fetch_wordbook_sources.mjs` (pulls pinned upstream source files)
- `./scripts/refresh_wordbooks.sh` (fetch + import + verify + quality report one-shot)
- `data/sources/SOURCE_FETCH_MANIFEST.json` generated with per-file URL/SHA256
- `data/sources/WORDLIST_QUALITY_REPORT.md` generated with quality metrics

## Build & Test Commands

1. `node scripts/verify_wordbooks.mjs` -> PASS
2. `./android/gradlew -p android :app:assembleDebug` -> PASS
3. `./android/gradlew -p android :app:testDebugUnitTest --rerun-tasks` -> PASS
4. `./android/gradlew -p android :app:connectedDebugAndroidTest` -> PASS (`15 tests` on device)
5. `./android/gradlew -p android :app:assembleRelease` -> PASS
6. `./scripts/build_signed_release.sh` -> PASS (installable signed APK generated)

## Acceptance Scenario Coverage

Automated acceptance suite (`AcceptanceFlowTest`) passed on real device:

1. `Shape of You` returns lyrics and match count `>= 5` -> PASS
2. Non-existent song returns not found state -> PASS
3. All wordbooks disabled then search prompts enable-at-least-one -> PASS
4. Switching wordbook changes hit count and source labels -> PASS
5. Favorite from result enters favorites state immediately -> PASS
6. Delete favorite syncs back to result state -> PASS
7. Network-error path yields retryable error state -> PASS
8. Debug/Release build and release install/startup smoke -> PASS

Reference report:
- `android/app/build/outputs/androidTest-results/connected/debug/TEST-24090RA29G - 14-_app-.xml`

## Unit Test Coverage (`12/12`)

- `LyricsRepositoryTest` (5)
- `LyricsProcessorTest` (3)
- `VocabMatcherTest` (3)
- `ResultScreenLogicTest` (1)

All passed with `failures=0` and `errors=0`.

## Connected Android Tests (`15/15`)

- `AcceptanceFlowTest` (7)
- `FavoriteDaoTest` (3)
- `SettingsRepositoryTest` (2)
- `WordbookRepositoryTest` (3)

All passed with `failures=0` and `errors=0`.

## Release Artifacts

- Unsigned: `android/app/build/outputs/apk/release/app-release-unsigned.apk`
- Signed (installable): `android/app/build/outputs/apk/release/app-release.apk`
- Signing mode used: `debug-keystore` (local QA mode)
- SHA256 (`app-release.apk`):
  - `df25f387dd0e02c7ad02e9014fd58be9413897bbf3eeecd8675d1c94780d45b0`

## Runtime Smoke Check

- `adb install -r android/app/build/outputs/apk/release/app-release.apk` -> PASS
- `adb shell am start -W -n com.singword.app/.MainActivity` -> PASS
- `adb shell monkey -p com.singword.app -c android.intent.category.LAUNCHER 1` -> PASS
- Logcat scan: no `FATAL EXCEPTION` for `com.singword.app`.

## Notes

- On Xiaomi devices, `connectedDebugAndroidTest` may occasionally hit `INSTALL_FAILED_USER_RESTRICTED` if security prompt is not accepted in time; rerun after approval succeeds.
- Some Xiaomi ROM builds may return `No activities found to run` for `adb shell monkey ...`; use explicit `am start -W -n com.singword.app/.MainActivity` as the launch smoke check.
- `AcceptanceFlowTest` has been stabilized to avoid live network dependency in success-path assertions; network error behavior remains covered by dedicated failure-path case.
