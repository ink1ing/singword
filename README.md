# 🎵 SingWord

**听歌背单词** — 输入英文歌名，自动匹配四六级/雅思/托福高频词汇并展示释义。

## 仓库结构

```text
.
├─ app/                      # Android app module
├─ ios/                      # iOS (Swift 原生工程)
├─ data/sources/             # 词书来源与质量报告
├─ scripts/                  # 词书处理与测试脚本
├─ QA_CHECKLIST.md           # Android 验收清单
├─ IOS_QA_CHECKLIST.md       # iOS 验收清单
└─ plans.md                  # 实施计划
```

## 产品定位

一个轻量级的英语学习辅助工具。通过英文歌词这一天然语料，帮助用户在听歌的同时复习考试高频词汇。

## 核心功能

| 功能 | 说明 |
|------|------|
| 歌词搜索 | 输入歌名，在线获取英文歌词 |
| 重名处理 | 搜索后先给出最多 5 条候选歌曲，由用户手动确认 |
| 词汇匹配 | 歌词分词后与本地词表比对，返回命中词+中文释义 |
| 词表选择 | 设置中统一配置：CET-4 / CET-6 / IELTS / TOEFL |
| 收藏夹 | 收藏感兴趣的词汇，方便后续复习 |
| 关于页 | 提供项目仓库与词书构建来源详细 URL |

## 技术栈

| 层面 | 选择 |
|------|------|
| 平台 | Android + iOS |
| 语言 | Kotlin（Android） / Swift（iOS） |
| 架构 | MVVM + Repository |
| UI | Jetpack Compose + Material 3（Android） / SwiftUI（iOS） |
| 网络 | Retrofit + OkHttp（Android） / URLSession（iOS） |
| 本地存储 | Room（Android 收藏） + JSON 文件持久化（iOS 收藏） + Assets JSON（词表） |
| 异步 | Kotlin Coroutines + Flow（Android） / Swift Concurrency（iOS） |

## 歌词获取策略

```
用户输入歌名
    ↓
lrclib.net API（主，免费无key）
    ↓ 搜不到
Genius API（备选，需API Token，后续接入）
    ↓
歌词文本
```

- **lrclib.net**：`GET https://lrclib.net/api/search?q={query}`，返回 JSON 含 `plainLyrics`
- **Genius**：预留接口，V2 接入

## 词汇处理流程

```
歌词文本
  → split(空格/换行)
  → replace(标点 → 空)
  → toLowerCase()
  → distinct/去重
  → 查本地词表 Map<String, WordEntry>
  → 命中词 + 释义，按字母排序
```

## 词表数据

本地 JSON，随 App 打包在 `assets/` 下：

| 文件 | 内容 | 规模 |
|------|------|------|
| `cet4.json` | 四级词汇（开源导入完整集） | 2,675 词 |
| `cet6.json` | 六级词汇（开源导入扩展集） | 2,219 词 |
| `ielts.json` | 雅思高频词 | 1,922 词 |
| `toefl.json` | 托福高频词（含 4300 扩展） | 9,971 词 |

JSON 格式：
```json
[
  { "word": "abandon", "pos": "v.", "def": "放弃；抛弃" },
  { "word": "ability", "pos": "n.", "def": "能力；才能" }
]
```

词表可复现导入（会重建 `cet4/cet6/ielts/toefl` 与 `manifest`）：
```bash
node scripts/import_wordbooks_from_sources.mjs
```

拉取词书源（固定 commit，可重复）：
```bash
node scripts/fetch_wordbook_sources.mjs
```

一键刷新词书（拉取源 + 导入 + 校验）：
```bash
./scripts/refresh_wordbooks.sh
```
生成后会产出：
- `data/sources/SOURCE_FETCH_MANIFEST.json`（每个源文件 URL + SHA256）
- `data/sources/WORDLIST_QUALITY_REPORT.md`（质量统计报告）

词表一致性校验（发布前建议执行）：
```bash
node scripts/verify_wordbooks.mjs
```

## UI 设计

- **主题**：暗色模式，主背景 `#3A3A3A`
- **页面**：搜索首页 / 候选歌曲页 / 结果页 / 设置页 / 收藏页 / 关于页
- **导航**：Bottom Navigation（搜索 / 收藏 / 设置），结果页为二级路由

## 本地开发

```bash
# 先复制本地配置（包含 sdk.dir 与可选 Genius 配置）
cp local.properties.example local.properties

./gradlew :app:assembleDebug
./gradlew :app:testDebugUnitTest
./gradlew :app:connectedDebugAndroidTest

# 词表资产校验（计数/排序/重复/manifest 对齐）
node scripts/verify_wordbooks.mjs

# 推荐：稳定真机测试（跳过 EmulatorOnly）
./scripts/run_android_tests.sh device

# 生成可安装 release 包（自动签名）
./scripts/build_signed_release.sh

# 全量 instrumentation（建议在模拟器）
./scripts/run_android_tests.sh emulator
# 或者（Gradle 直跑）
./gradlew :app:connectedDebugAndroidTest -PincludeEmulatorOnlyTests=true
```

## iOS 本地开发（Swift 原生）

- 工程路径：`ios/singword.xcodeproj`
- 代码路径：`ios/singword/`
- 词表资源：`ios/singword/Resources/wordbooks/`

命令行构建：

```bash
cd ios
xcodebuild -project singword.xcodeproj -scheme singword -destination 'platform=iOS Simulator,name=iPhone 17' build
```

iOS 验收清单见：

- `IOS_QA_CHECKLIST.md`

## 当前实现状态

- Android：主流程、Room 收藏、词表切换、主歌词源（lrclib）已完成
- iOS（Swift 原生）：主流程、候选选择、词汇匹配、收藏、设置、关于页已完成并可编译运行
- 预留：Genius fallback（默认关闭）
- 资源：Android 词表位于 `app/src/main/assets/wordbooks/`；iOS 词表位于 `ios/singword/Resources/wordbooks/`
- 词书下载尝试记录：`data/sources/BOOK_DOWNLOAD_ATTEMPTS.md`
