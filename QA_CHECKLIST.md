# SingWord QA Checklist

Reference behavior spec:

- `docs/behavior-spec.md`

## Core Flow

1. Search `Shape of You`, verify lyric result appears and hit words >= 5.
2. Search an invalid song name, verify `未找到歌词` appears and error code maps to lyrics-not-found behavior.
3. Submit empty input, verify `请输入歌名`.
4. Disable all wordbooks (attempt), verify app blocks and shows `至少保留一个词表开启`.
5. Search with no enabled wordbook state, verify `请先在设置中选择至少一个词表`.
6. Change enabled wordbooks and search again, verify hit count/source changes.
7. Favorite one word in result page, verify appears in Favorites page immediately.
8. Delete favorite by swipe and icon button, verify item removed immediately.
9. Disable network and search, verify `网络异常，请检查连接后重试`.
10. In network/provider failure states, verify retry entry is visible and works.

## Platform Consistency

1. Primary tabs remain `Search`, `Favorites`, `Settings`.
2. Secondary pages (`Candidates`, `Result`, `About`) are not bottom tabs.
3. Search CTA stays `下一步`.
4. Search placeholder stays `例如：California Hotel`.
5. Favorites empty state stays `空空如也`.
6. Theme default behavior is `SYSTEM`.
7. Default enabled wordbook state is only `CET-4=true`.

## Build Validation

1. `node scripts/verify_wordbooks.mjs` succeeds.
2. `./android/gradlew -p android :app:testDebugUnitTest` succeeds.
3. `./android/gradlew -p android :app:lintDebug` succeeds.
4. `./android/gradlew -p android :app:assembleDebug` succeeds.
5. `./android/gradlew -p android :app:assembleRelease` succeeds.
6. `./scripts/build_signed_release.sh` produces installable signed APK.
7. Install release APK and launch app successfully.

## AndroidTest Strategy

1. Real device stable run: `./scripts/run_android_tests.sh device` (skip `@EmulatorOnly` tests).
2. Emulator full run: `./scripts/run_android_tests.sh emulator`.
3. Gradle direct full run (optional): `./android/gradlew -p android :app:connectedDebugAndroidTest -PincludeEmulatorOnlyTests=true`.
4. GitHub manual full run: `Android Connected Tests` workflow.

## Release Gate

1. Build validation items must all pass.
2. Core flow items must all pass.
3. Platform consistency items must all pass.
4. Any deliberate Android/iOS divergence must be recorded in `docs/behavior-spec.md`.
