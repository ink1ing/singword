import SwiftUI

struct LibraryListScreen: View {
    @ObservedObject var viewModel: LibraryImportStore
    let favoriteWords: Set<String>
    let downloadedSongIDs: Set<String>
    let onToggleFavorite: (MatchedWord) -> Void
    let onToggleSongFavorite: (SongMatchSnapshot) -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if viewModel.tracks.isEmpty {
                LibraryImportScreen(viewModel: viewModel)
            } else {
                List {
                    Section {
                        ImportStatusCard(progress: viewModel.progress)
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .listRowBackground(Color.clear)
                    }

                    ForEach(viewModel.groupedTracks, id: \.0) { section in
                        Section(section.0) {
                            ForEach(section.1) { track in
                                NavigationLink {
                                    let favoriteSnapshot = track.asFavoriteSnapshot(match: viewModel.match(for: track.id))
                                    LibraryTrackDetailScreen(
                                        track: track,
                                        match: viewModel.match(for: track.id),
                                        favoriteWords: favoriteWords,
                                        isSongFavorite: downloadedSongIDs.contains(favoriteSnapshot.id),
                                        onToggleFavorite: onToggleFavorite,
                                        onToggleSongFavorite: {
                                            onToggleSongFavorite(favoriteSnapshot)
                                        },
                                        onRetry: {
                                            viewModel.retry(track)
                                        }
                                    )
                                } label: {
                                    LibraryTrackRow(track: track, match: viewModel.match(for: track.id))
                                }
                                .listRowBackground(surfaceColor)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(backgroundColor.ignoresSafeArea())
            }
        }
        .navigationTitle("资料库")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("导入") {
                    viewModel.importScreenPresented = true
                }
            }
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground
    }

    private var surfaceColor: Color {
        colorScheme == .dark ? SingWordPalette.darkSurface : SingWordPalette.lightSurface
    }
}

private struct LibraryTrackRow: View {
    let track: ImportedTrack
    let match: ImportedTrackMatch?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(track.title)
                .font(SingWordTypography.titleMedium)

            Text(track.artistName.isEmpty ? "未知艺人" : track.artistName)
                .font(SingWordTypography.bodyMedium)
                .foregroundStyle(.secondary)

            Text(statusLine)
                .font(SingWordTypography.labelMedium)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var statusLine: String {
        switch track.status {
        case .matched:
            return "已匹配 · \(match?.matchedWords.count ?? 0) 个词"
        case .matchingLyrics:
            return "正在识别歌词"
        case .queued:
            return "等待识别"
        case .unmatched:
            return "未匹配 · \(track.failureMessage)"
        case .failed:
            return "失败 · \(track.failureMessage)"
        case .cancelled:
            return "已取消"
        }
    }
}
