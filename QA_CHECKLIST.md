# SingWord QA Checklist

## Core Flow

1. Search `Shape of You`, verify lyric result appears and hit words >= 5.
2. Search an invalid song name, verify `未找到歌词` appears.
3. Disable all wordbooks (attempt), verify app blocks and shows warning.
4. Change enabled wordbooks and search again, verify hit count/source changes.
5. Favorite one word in result page, verify appears in Favorites page.
6. Delete favorite by swipe and icon button, verify item removed.
7. Disable network and search, verify network error message.

## Build Validation

1. `./gradlew :app:assembleDebug` succeeds.
2. `./gradlew :app:assembleRelease` succeeds.
3. `./scripts/build_signed_release.sh` produces installable signed APK.
4. Install release APK and launch app successfully.

## AndroidTest Strategy

1. Real device stable run: `./scripts/run_android_tests.sh device` (skip `@EmulatorOnly` tests).
2. Emulator full run: `./scripts/run_android_tests.sh emulator`.
3. Gradle direct full run (optional): `./gradlew :app:connectedDebugAndroidTest -PincludeEmulatorOnlyTests=true`.
