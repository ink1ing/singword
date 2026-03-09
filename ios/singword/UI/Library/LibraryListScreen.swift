import SwiftUI

struct LibraryListScreen: View {
    @ObservedObject var viewModel: LibraryImportStore
    let favoriteWords: Set<String>
    let onToggleFavorite: (MatchedWord) -> Void

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
                                    LibraryTrackDetailScreen(
                                        track: track,
                                        match: viewModel.match(for: track.id),
                                        favoriteWords: favoriteWords,
                                        onToggleFavorite: onToggleFavorite,
                                        onRetry: {
                                            viewModel.retry(track)
                                        }
                                    )
                                } label: {
                                    LibraryTrackRow(track: track, match: viewModel.match(for: track.id))
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("导入") {
                    viewModel.importScreenPresented = true
                }
            }
        }
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
