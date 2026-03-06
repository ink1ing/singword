# SingWord Cross-Platform Behavior Spec

## Purpose

This document defines the user-visible behavior that Android and iOS should keep aligned.
When the two platforms differ, this file is the source of truth for future fixes.

## Product Scope

- Input a song name.
- Fetch up to 5 lyric candidates from `lrclib` first.
- Let the user choose the intended song when names are ambiguous.
- Match lyrics against enabled local wordbooks.
- Support favorites, settings, and about pages.

## Navigation Model

- Primary tabs: `Search`, `Favorites`, `Settings`.
- Secondary routes: `Candidates`, `Result`, `About`.
- `Candidates`, `Result`, and `About` do not appear as bottom tabs.
- Page changes should be immediate and should not depend on long transition animations.

## Search Flow

1. User enters a query and taps `下一步`.
2. Empty input blocks the request and shows `请输入歌名`.
3. If no wordbook is enabled, block the request and show `请先在设置中选择至少一个词表`.
4. Search lyrics candidates with limit `5`.
5. On success, go to candidate selection.
6. On candidate selection, fetch or reuse lyrics and run token matching.
7. Result page shows:
   - track name
   - artist name
   - provider
   - matched words
   - empty-result state when no words match

## Error Codes

Both platforms should preserve these logical states:

- `EMPTY_QUERY`
- `NO_WORDBOOK_SELECTED`
- `WORDBOOK_MISSING_ASSET`
- `WORDBOOK_PARSE_ERROR`
- `LYRICS_NOT_FOUND`
- `NETWORK_ERROR`
- `PROVIDER_ERROR`
- `UNKNOWN`

Swift naming may remain camelCase and Kotlin naming may remain upper snake case, but the semantic mapping must stay 1:1.

## Error Messages

User-visible copy should stay aligned:

- Empty query: `请输入歌名`
- No enabled wordbook before search: `请先在设置中选择至少一个词表`
- Attempt to disable the last enabled wordbook: `至少保留一个词表开启`
- Lyrics not found: `未找到歌词`
- Network failure: `网络异常，请检查连接后重试`
- Missing wordbook asset: `词表文件缺失：{assetPath}`
- Wordbook parse failure: `词表解析失败：{assetPath}`

Provider-specific messages may vary internally, but user-facing fallback copy should still map to the same logical error bucket.

## Provider Rules

- Primary provider: `lrclib`
- Secondary provider: `genius`
- Secondary provider is disabled by default.
- Candidate provider should be visible in candidate and result flows where available.
- Fallback ordering:
  - Primary `NotFound` may try secondary.
  - Primary `NetworkError` should fail fast.
  - Primary `ProviderError` should surface as provider failure unless fallback policy changes explicitly.

## Wordbook Rules

- Supported wordbooks:
  - `CET-4`
  - `CET-6`
  - `IELTS`
  - `TOEFL`
- Default enabled state:
  - `CET-4 = true`
  - others = `false`
- At least one wordbook must remain enabled.
- Matching output must be:
  - de-duplicated
  - alphabetically sorted
  - tagged with source wordbook label

## Theme Rules

- Theme modes:
  - `SYSTEM`
  - `LIGHT`
  - `DARK`
- Default behavior: follow system theme.
- Settings UI may differ visually between platforms, but the meaning of the toggle or picker must stay equivalent.

## Favorites Rules

- Favorite identity is keyed by normalized word.
- Favoriting from result page should update favorites page immediately.
- Removing from favorites should update dependent UI immediately.
- Persistence is local-only in current versions.

## Retry Behavior

- Retry entry points should be shown for:
  - `NETWORK_ERROR`
  - `PROVIDER_ERROR`
- Retry should repeat the latest meaningful step:
  - selected candidate retry if a candidate is already chosen
  - otherwise search again from the query

## Copy Alignment Targets

The following labels should remain aligned unless changed intentionally:

- Search helper text: `输入歌名，提取高频词`
- Search placeholder: `例如：California Hotel`
- Search CTA: `下一步`
- Favorites empty state: `空空如也`
- Settings title groups:
  - `主题模式`
  - `词表`
  - `关于`

## CI Gates

Every cross-platform change should preserve:

- Android:
  - wordbook verification
  - unit tests
  - lint
  - debug build
  - release build
- iOS:
  - simulator build

## Change Policy

- If only one platform changes user-visible behavior, update this spec in the same change or document the temporary divergence explicitly.
- If behavior is intentionally split by platform, add a short note here explaining why.
