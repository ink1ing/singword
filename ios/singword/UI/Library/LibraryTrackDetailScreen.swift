import SwiftUI

struct LibraryTrackDetailScreen: View {
    let track: ImportedTrack
    let match: ImportedTrackMatch?
    let favoriteWords: Set<String>
    let isSongFavorite: Bool
    let onToggleFavorite: (MatchedWord) -> Void
    let onToggleSongFavorite: () -> Void
    let onRetry: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var localSongFavorite: Bool

    init(
        track: ImportedTrack,
        match: ImportedTrackMatch?,
        favoriteWords: Set<String>,
        isSongFavorite: Bool,
        onToggleFavorite: @escaping (MatchedWord) -> Void,
        onToggleSongFavorite: @escaping () -> Void,
        onRetry: @escaping () -> Void
    ) {
        self.track = track
        self.match = match
        self.favoriteWords = favoriteWords
        self.isSongFavorite = isSongFavorite
        self.onToggleFavorite = onToggleFavorite
        self.onToggleSongFavorite = onToggleSongFavorite
        self.onRetry = onRetry
        _localSongFavorite = State(initialValue: isSongFavorite)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(track.title)
                        .font(SingWordTypography.titleLarge)
                    if !track.artistName.isEmpty {
                        Text(track.artistName)
                            .font(SingWordTypography.bodyMedium)
                            .foregroundStyle(.secondary)
                    }
                    if !track.albumTitle.isEmpty {
                        Text(track.albumTitle)
                            .font(SingWordTypography.labelMedium)
                            .foregroundStyle(.secondary)
                    }
                    Text(detailStatusLine)
                        .font(SingWordTypography.labelMedium)
                        .foregroundStyle(.secondary)

                    Button(action: onToggleSongFavorite) {
                        HStack(spacing: 8) {
                            Image(systemName: localSongFavorite ? "heart.fill" : "heart")
                            Text(localSongFavorite ? "已收藏" : "收藏")
                                .font(SingWordTypography.bodyMedium)
                        }
                        .foregroundStyle(primaryColor)
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            localSongFavorite.toggle()
                        }
                    )
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(surfaceColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                if let match {
                    Text("相关单词 (\(match.matchedWords.count))")
                        .font(SingWordTypography.titleMedium)
                        .foregroundStyle(.secondary)

                    if match.matchedWords.isEmpty {
                        Text("歌词已识别，但当前词书没有命中单词。")
                            .font(SingWordTypography.bodyMedium)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(match.matchedWordItems) { word in
                            HStack(alignment: .top, spacing: 10) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Text(word.word)
                                            .font(SingWordTypography.titleMedium)
                                        Text(word.pos)
                                            .font(SingWordTypography.labelMedium)
                                            .foregroundStyle(.secondary)
                                        Text(word.source)
                                            .font(SingWordTypography.labelSmallBold)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(Color.sourceTag(word.source).opacity(0.2))
                                            .foregroundStyle(Color.sourceTag(word.source))
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    }

                                    Text(word.definition)
                                        .font(SingWordTypography.bodyMedium)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer(minLength: 8)

                                Button {
                                    onToggleFavorite(word)
                                } label: {
                                    Image(systemName: favoriteWords.contains(word.word) ? "heart.fill" : "heart")
                                        .foregroundStyle(favoriteWords.contains(word.word) ? Color.singWordError : .secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(14)
                            .background(surfaceColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(track.failureMessage.isEmpty ? "当前没有可展示的识别结果。" : track.failureMessage)
                            .font(SingWordTypography.bodyMedium)
                            .foregroundStyle(track.status == .matched ? .secondary : Color.singWordError)

                        if track.status == .unmatched || track.status == .failed || track.status == .cancelled {
                            Button("重试匹配", action: onRetry)
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(surfaceColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(backgroundColor.ignoresSafeArea())
        .navigationTitle("资料库歌曲")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var detailStatusLine: String {
        switch track.status {
        case .matched:
            return "已匹配 · 来源 \(match?.lyricsProvider ?? "-") · 共 \(match?.totalTokens ?? 0) 个单词"
        case .matchingLyrics:
            return "正在识别歌词"
        case .queued:
            return "等待识别"
        case .unmatched:
            return "未匹配"
        case .failed:
            return "失败"
        case .cancelled:
            return "已取消"
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground
    }

    private var surfaceColor: Color {
        colorScheme == .dark ? SingWordPalette.darkSurface : SingWordPalette.lightSurface
    }

    private var primaryColor: Color {
        colorScheme == .dark ? SingWordPalette.darkLink : SingWordPalette.lightLink
    }
}
