# iOS QA Checklist (SingWord)

Reference behavior spec:

- `docs/behavior-spec.md`

## 构建

- [x] `xcodebuild -project ios/singword.xcodeproj -scheme singword -destination 'platform=iOS Simulator,name=iPhone 17' build` 成功
- [ ] Xcode 真机 Debug 运行成功

## 搜索主流程

- [ ] 输入有效歌名（如 `Shape of You`）后进入候选页
- [ ] 候选页可看到来源 `lrclib`
- [ ] 选择候选后进入结果页并看到命中词
- [ ] 结果页返回候选页、返回搜索页链路正常
- [ ] 子页面（候选/结果）TabBar 自动隐藏
- [ ] 搜索占位词为 `例如：California Hotel`
- [ ] 搜索按钮文案为 `下一步`

## 异常处理

- [ ] 空输入时提示 `请输入歌名`
- [ ] 无词书可用时提示 `请先在设置中选择至少一个词表`
- [ ] 网络断开时提示 `网络异常，请检查连接后重试`
- [ ] 歌词不存在时提示 `未找到歌词`
- [ ] 网络错误场景显示 `重试` 按钮可恢复

## 词表与匹配

- [ ] 设置页默认仅 `CET-4` 开启
- [ ] 尝试关闭最后一个词表时提示 `至少保留一个词表开启`
- [ ] 切换词表后重新搜索，命中词数量有变化
- [ ] 词条标签颜色与来源匹配（CET-4/CET-6/IELTS/TOEFL）

## 收藏

- [ ] 结果页点爱心后进入收藏页可见该词
- [ ] 再次点爱心可取消收藏
- [ ] 收藏页右滑删除生效
- [ ] 重启 App 后收藏仍存在（JSON 持久化）

## 设置与关于

- [ ] 主题切换（系统/浅色/深色）实时生效
- [ ] 默认主题行为为 `跟随系统`
- [ ] 关于页外链可点击打开
- [ ] 关于页异常 URL 不崩溃（已加保护）

## 发布门槛

- [ ] 核心主流程全部通过
- [ ] 异常处理全部通过
- [ ] 与 `docs/behavior-spec.md` 的用户可见行为一致

## 兼容性建议

- [ ] iPhone 17（26.2）
- [ ] iPhone SE 尺寸（小屏）
- [ ] iPad 竖屏
