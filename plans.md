# SingWord iOS 原生迁移计划（Swift）

## 目标与范围

- 目标：将当前 Android 版 SingWord 核心能力迁移到 `ios/singword` 空 iOS 工程，使用 Swift 原生实现（SwiftUI + URLSession + UserDefaults + 本地 JSON 文件持久化）。
- 范围：
  - 搜索歌曲并拉取歌词候选（lrclib 主源）。
  - 选择候选歌曲后进行词汇命中匹配（CET-4/CET-6/IELTS/TOEFL）。
  - 结果页收藏/取消收藏。
  - 收藏夹浏览与删除。
  - 设置页词表开关（至少保留一个）、主题模式切换。
  - 关于页展示项目与词书来源链接。
- 本次不做：
  - Genius 真正抓词（与 Android 对齐：预留）。
  - 复杂离线缓存策略与增量同步。

## Android -> iOS 模块映射

- `data/remote` -> `Networking/*`（`LyricsDataSource` / `LrclibLyricsDataSource` / `LyricsRepository`）。
- `data/local/wordbook` -> `Data/Wordbooks/*`（词表模型、目录、加载器、错误类型）。
- `data/local/prefs` -> `Data/Settings/*`（`UserDefaults` 持久化词表开关与主题）。
- `data/local/db` -> `Data/Favorites/*`（JSON 文件持久化收藏，按时间倒序）。
- `domain/*` -> `Domain/*`（分词与匹配逻辑）。
- `ui/*` + `navigation/*` -> `UI/*`（Tab + NavigationStack + 页面拆分）。

## 目录与文件规划

- `ios/singword/App/`
  - `SingWordApp.swift`（应用入口、全局依赖注入、主题控制）
  - `AppCoordinator.swift`（全局容器/共享状态）
- `ios/singword/Domain/`
  - `LyricsProcessor.swift`
  - `VocabMatcher.swift`
  - `MatchedWord.swift`
- `ios/singword/Data/Wordbooks/`
  - `WordEntry.swift`
  - `WordbookId.swift`
  - `WordbookMeta.swift`
  - `WordbookLoadResult.swift`
  - `WordbookRepository.swift`
- `ios/singword/Data/Settings/`
  - `AppThemeMode.swift`
  - `SettingsRepository.swift`
- `ios/singword/Data/Favorites/`
  - `FavoriteWord.swift`
  - `FavoriteRepository.swift`
- `ios/singword/Networking/`
  - `LyricsResult.swift`
  - `LyricsCandidate.swift`
  - `LyricsCandidateResult.swift`
  - `LyricsDataSource.swift`
  - `LrclibLyricsDataSource.swift`
  - `GeniusLyricsDataSource.swift`
  - `LyricsRepository.swift`
- `ios/singword/UI/`
  - `Search/SearchViewModel.swift`
  - `Search/SearchScreen.swift`
  - `Search/SongCandidatesScreen.swift`
  - `Search/ResultScreen.swift`
  - `Favorites/FavoritesViewModel.swift`
  - `Favorites/FavoritesScreen.swift`
  - `Settings/SettingsViewModel.swift`
  - `Settings/SettingsScreen.swift`
  - `Settings/AboutSingWordScreen.swift`
  - `Theme/SingWordPalette.swift`
- `ios/singword/Resources/wordbooks/`
  - `cet4.json` / `cet6.json` / `ielts.json` / `toefl.json` / `manifest.json`

## 迁移执行步骤

1. 建立 iOS 代码骨架
- 新建分层目录与模型类型。
- 落地错误枚举与 Result 状态对象，保持与 Android 语义一致。

2. 迁移核心业务逻辑
- 迁移 `LyricsProcessor`（标点清洗、去重、过滤长度<=1）。
- 迁移 `VocabMatcher`（按字母排序，保留 source 标签）。

3. 迁移词表与设置
- 复制 JSON 词表到 iOS 资源目录。
- 实现 `WordbookRepository`：从 Bundle 读取 JSON，缓存 map，支持多词表合并。
- 实现 `SettingsRepository`：词表开关 + 主题模式持久化，保证至少 1 个词表开启。

4. 迁移歌词网络层
- `URLSession` 调用 `https://lrclib.net/api/search?q=`。
- 网络/服务错误映射到统一结果类型。
- 实现主源与 fallback 策略（fallback 仅在 not found 触发）。

5. 迁移收藏层
- 用本地 JSON 文件替代 Room：增删查 + 按时间倒序。
- 提供“收藏单词集合”以驱动结果页爱心状态。

6. 迁移 UI 与导航
- 主体结构：`TabView(搜索/收藏/设置)`。
- 搜索流：搜索页 -> 候选页 -> 结果页。
- 收藏页支持删除。
- 设置页支持词表开关、主题切换、进入关于页。
- 关于页展示外链并可点击打开。

7. 编译与验证
- 运行 `xcodebuild` 对 iOS 工程进行编译验证。
- 人工走查关键路径：
  - 搜索存在歌曲 -> 选候选 -> 出命中词。
  - 空搜索、词表全关、网络异常提示。
  - 收藏/取消收藏与收藏夹联动。
  - 词表开关影响命中结果。

## 风险与处理

- 资源打包风险：若 JSON 未进 Bundle，将出现词表缺失。
  - 处理：使用工程根组同步 + 编译验证 + 运行时错误提示。
- 网络源不稳定：lrclib 返回慢或异常。
  - 处理：超时、错误分类、重试入口。
- 收藏持久化一致性：并发写入可能覆盖。
  - 处理：`actor` 串行化读写。

## 完成定义（DoD）

- iOS 工程可编译通过。
- 核心功能在 iOS 端可用，并与 Android 行为基本一致。
- `plans.md` 与实际代码一致，且迁移路径可复现。
- 关键代码已按模块分层，不是单文件堆砌。

## 执行状态

- [x] 计划输出
- [x] 代码迁移完成
- [x] 构建验证（`xcodebuild` 成功）
- [x] iOS 验收清单输出（`IOS_QA_CHECKLIST.md`）
- [x] 结果回报
