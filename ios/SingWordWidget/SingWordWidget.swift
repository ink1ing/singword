import SwiftUI
import WidgetKit

struct SingWordWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: SearchWidgetSnapshot
    let themeMode: AppThemeMode
}

struct WidgetSnapshotReader {
    private let fileManager = FileManager.default

    func loadSnapshot() -> SearchWidgetSnapshot {
        guard
            let directory = SingWordShared.sharedContainerDirectory(fileManager: fileManager),
            let data = try? Data(contentsOf: directory.appendingPathComponent(SingWordShared.recentSearchesFileName)),
            let snapshots = try? JSONDecoder().decode([RecentSearchWidgetSnapshot].self, from: data),
            let latest = snapshots.first
        else {
            return SearchWidgetSnapshot(
                trackName: "Shape of You",
                artistName: "Ed Sheeran",
                words: [
                    WidgetWordSnapshot(word: "bar", pos: "n.", definition: "酒吧"),
                    WidgetWordSnapshot(word: "castle", pos: "n.", definition: "城堡"),
                    WidgetWordSnapshot(word: "friend", pos: "n.", definition: "朋友"),
                    WidgetWordSnapshot(word: "sweet", pos: "adj.", definition: "甜的")
                ],
                updatedAt: Date().timeIntervalSince1970
            )
        }

        return SearchWidgetSnapshot(
            trackName: latest.trackName,
            artistName: latest.artistName,
            words: latest.matchedWords,
            updatedAt: latest.timestamp
        )
    }

    func loadThemeMode() -> AppThemeMode {
        let raw = SingWordShared.sharedDefaults()?.string(forKey: "theme_mode") ?? AppThemeMode.system.rawValue
        return AppThemeMode(rawValue: raw) ?? .system
    }
}

struct SingWordWidgetProvider: TimelineProvider {
    private let reader = WidgetSnapshotReader()

    func placeholder(in context: Context) -> SingWordWidgetEntry {
        SingWordWidgetEntry(date: Date(), snapshot: reader.loadSnapshot(), themeMode: .system)
    }

    func getSnapshot(in context: Context, completion: @escaping (SingWordWidgetEntry) -> Void) {
        completion(
            SingWordWidgetEntry(
                date: Date(),
                snapshot: reader.loadSnapshot(),
                themeMode: reader.loadThemeMode()
            )
        )
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SingWordWidgetEntry>) -> Void) {
        let entry = SingWordWidgetEntry(
            date: Date(),
            snapshot: reader.loadSnapshot(),
            themeMode: reader.loadThemeMode()
        )
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct SingWordWidgetEntryView: View {
    let entry: SingWordWidgetProvider.Entry

    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var systemColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("from「\(entry.snapshot.trackName)」")
                .font(SingWordTypography.titleLarge)
                .foregroundStyle(primaryTextColor)
                .lineLimit(family == .systemLarge ? 2 : 1)

            VStack(alignment: .leading, spacing: family == .systemLarge ? 10 : 8) {
                ForEach(displayWords) { word in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(word.word)
                            .font(SingWordTypography.titleMedium)
                            .foregroundStyle(primaryTextColor)
                            .lineLimit(1)

                        if !word.pos.isEmpty {
                            Text(word.pos)
                                .font(SingWordTypography.bodyMedium)
                                .foregroundStyle(secondaryTextColor)
                                .lineLimit(1)
                        }

                        Text(word.definition)
                            .font(SingWordTypography.bodyMedium)
                            .foregroundStyle(secondaryTextColor)
                            .lineLimit(1)

                        Spacer(minLength: 0)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(family == .systemLarge ? 18 : 16)
        .containerBackground(backgroundColor, for: .widget)
    }

    private var displayWords: ArraySlice<WidgetWordSnapshot> {
        let maxCount = family == .systemLarge ? 8 : 4
        return entry.snapshot.words.prefix(maxCount)
    }

    private var resolvedColorScheme: ColorScheme {
        switch entry.themeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return systemColorScheme
        }
    }

    private var backgroundColor: Color {
        resolvedColorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground
    }

    private var primaryTextColor: Color {
        resolvedColorScheme == .dark ? SingWordPalette.darkTextPrimary : SingWordPalette.lightTextPrimary
    }

    private var secondaryTextColor: Color {
        resolvedColorScheme == .dark ? SingWordPalette.darkTextSecondary : SingWordPalette.lightTextSecondary
    }
}

struct SingWordWidget: Widget {
    let kind: String = SingWordShared.widgetKind

    init() {
        SingWordFontRegistrar.registerAll()
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SingWordWidgetProvider()) { entry in
            SingWordWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SingWord 词汇")
        .description("展示最近一次歌词匹配中的高频词。")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    SingWordWidget()
} timeline: {
    SingWordWidgetEntry(
        date: .now,
        snapshot: SearchWidgetSnapshot(
            trackName: "Shape of You",
            artistName: "Ed Sheeran",
            words: [
                WidgetWordSnapshot(word: "bar", pos: "n.", definition: "酒吧"),
                WidgetWordSnapshot(word: "castle", pos: "n.", definition: "城堡"),
                WidgetWordSnapshot(word: "sweet", pos: "adj.", definition: "甜的"),
                WidgetWordSnapshot(word: "friend", pos: "n.", definition: "朋友")
            ],
            updatedAt: Date().timeIntervalSince1970
        ),
        themeMode: .system
    )
}
