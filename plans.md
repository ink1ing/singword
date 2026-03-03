# SingWord 开发计划

## Phase 1 — 项目骨架

> 目标：跑通 Android 项目，搭好 MVVM 架构

- [x] 初始化 Android 项目（Kotlin + Jetpack Compose）
- [x] 配置 Gradle 依赖（Retrofit, Room, Compose Navigation, Material 3）
- [x] 建立包结构：`data/` `domain/` `ui/` `di/`
- [x] 设置暗色主题（主色 `#3A3A3A`，配色方案）

## Phase 2 — 词表数据

> 目标：本地词表可加载、可查询

- [x] 准备 CET4/6 / IELTS / TOEFL 的 JSON 词表文件
- [x] 放入 `assets/wordbooks/` 目录
- [x] 实现 `WordbookRepository`：从 assets 读取 JSON → 解析为 `Map<String, WordEntry>`
- [x] 实现词表选择逻辑（SharedPreferences 存用户选择）

## Phase 3 — 歌词获取

> 目标：输入歌名 → 拿到歌词文本

- [x] 定义 `LyricsApi` 接口（Retrofit）
- [x] 实现 `LrclibService`：调用 lrclib.net 搜索 API
- [x] 预留 `GeniusService` 接口（暂不实现，返回空）
- [x] 实现 `LyricsRepository`：主 → fallback 逻辑

## Phase 4 — 核心匹配逻辑

> 目标：歌词 → 命中词汇列表

- [x] 实现 `LyricsProcessor`：分词 → 清洗标点 → 小写 → 去重
- [x] 实现 `VocabMatcher`：词列表 × 词表 → 命中结果
- [x] 数据类 `MatchedWord(word, pos, def, source)` — source 标记来自哪个词表

## Phase 5 — UI 搜索页

> 目标：用户输入歌名 → 展示匹配词汇

- [x] 搜索页 UI：搜索框 + 搜索按钮
- [x] 结果展示：歌曲信息卡片 + 命中词列表（LazyColumn）
- [x] 每个词条：单词、词性、释义、词表标签、收藏按钮
- [x] 空状态 / 加载中 / 错误状态处理
- [x] SearchViewModel：串联 搜索 → 匹配 全流程

## Phase 6 — 收藏功能

> 目标：用户可收藏/取消收藏词汇，独立页面查看

- [x] Room 数据库：`FavoriteWord` 表（word, pos, def, source, timestamp）
- [x] `FavoriteDao`：增删查
- [x] 收藏页 UI：按时间倒序展示所有收藏词，支持左滑删除
- [x] 搜索结果中的收藏按钮联动 Room 数据

## Phase 7 — 设置页

> 目标：统一配置词表选择

- [x] 设置页 UI：词表多选开关（CET-4 / CET-6 / IELTS / TOEFL）
- [x] SharedPreferences 持久化用户选择
- [x] 搜索时根据设置动态加载对应词表

## Phase 8 — 导航与整合

> 目标：三个 Tab 页面串联

- [x] Bottom Navigation：搜索 🔍 / 收藏 ⭐ / 设置 ⚙️
- [x] Compose Navigation 路由配置
- [x] 全局状态串联验证

## Phase 9 — 打磨与打包

> 目标：完善细节，输出 APK

- [x] UI 微调：字体、间距、动画过渡
- [x] 异常兜底：网络超时、歌词为空、词表加载失败
- [x] 构建 Release APK
- [x] 基本功能走查测试

---

## 验证计划

| 场景 | 验证方式 |
|------|----------|
| 搜索热门歌 "Shape of You" | 确认返回歌词 + 命中词 ≥ 5 个 |
| 搜索不存在的歌名 | 确认显示"未找到歌词"提示 |
| 切换词表后重新搜索 | 确认命中结果随词表变化 |
| 收藏 → 去收藏页查看 | 确认收藏列表正确 |
| 取消收藏 → 刷新 | 确认已移除 |
| 无网络状态搜索 | 确认显示网络错误提示 |
| 构建 Release APK | `./gradlew assembleRelease` 成功 |
