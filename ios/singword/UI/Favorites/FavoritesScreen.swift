import SwiftUI

struct FavoritesScreen: View {
    @ObservedObject var viewModel: FavoritesViewModel
    let favoriteWords: Set<String>
    let onToggleFavorite: (MatchedWord) -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if viewModel.songs.isEmpty && viewModel.favorites.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart")
                        .font(.system(size: 56))
                        .foregroundStyle(.secondary)
                    Text("空空如也")
                        .font(SingWordTypography.bodyMedium)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if !viewModel.songs.isEmpty {
                        Section("歌曲") {
                            ForEach(viewModel.songs) { song in
                                NavigationLink {
                                    OfflineSongDetailScreen(
                                        song: song,
                                        favoriteWords: favoriteWords,
                                        onToggleFavorite: onToggleFavorite
                                    )
                                } label: {
                                    FavoriteSongRow(song: song)
                                }
                                .listRowBackground(backgroundColor)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.removeSong(song)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }

                    if !viewModel.favorites.isEmpty {
                        Section("单词") {
                            ForEach(viewModel.favorites) { word in
                                FavoriteWordRow(word: word) {
                                    viewModel.removeFavorite(word)
                                }
                                .listRowBackground(backgroundColor)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.removeFavorite(word)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("收藏夹")
        .navigationBarTitleDisplayMode(.inline)
        .background(backgroundColor.ignoresSafeArea())
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground
    }
}

private struct FavoriteSongRow: View {
    let song: SongMatchSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(song.trackName)
                .font(SingWordTypography.titleMedium)

            Text(song.artistName.isEmpty ? "未知艺人" : song.artistName)
                .font(SingWordTypography.bodyMedium)
                .foregroundStyle(.secondary)

            Text("离线词汇 \(song.matchedWords.count) 个")
                .font(SingWordTypography.labelMedium)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

private struct FavoriteWordRow: View {
    let word: FavoriteWord
    let onDelete: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
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

                Text("收藏于 \(formatTimestamp(word.timestamp))")
                    .font(SingWordTypography.labelMedium)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .listRowSeparator(.hidden)
        .background(colorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground)
    }

    private func formatTimestamp(_ timestamp: TimeInterval) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
}

private struct OfflineSongDetailScreen: View {
    let song: SongMatchSnapshot
    let favoriteWords: Set<String>
    let onToggleFavorite: (MatchedWord) -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(song.trackName)
                        .font(SingWordTypography.titleLarge)
                    if !song.artistName.isEmpty {
                        Text(song.artistName)
                            .font(SingWordTypography.bodyMedium)
                            .foregroundStyle(.secondary)
                    }
                    Text("离线保存 | 共 \(song.totalTokens) 个单词，命中 \(song.matchedWords.count) 个")
                        .font(SingWordTypography.labelMedium)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(surfaceColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Text("相关单词 (\(song.matchedWords.count))")
                    .font(SingWordTypography.titleMedium)
                    .foregroundStyle(.secondary)

                ForEach(song.matchedWordItems) { word in
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle("离线歌曲")
        .navigationBarTitleDisplayMode(.inline)
        .background(backgroundColor.ignoresSafeArea())
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground
    }

    private var surfaceColor: Color {
        colorScheme == .dark ? SingWordPalette.darkSurface : SingWordPalette.lightSurface
    }
}
