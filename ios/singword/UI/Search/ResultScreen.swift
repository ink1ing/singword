import SwiftUI

struct ResultScreen: View {
    let uiState: SearchUiState
    let favorites: Set<String>
    let isDownloaded: Bool
    let onToggleFavorite: (MatchedWord) -> Void
    let onDownload: () -> Void
    let onRetry: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if uiState.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = uiState.error {
                VStack(spacing: 12) {
                    Text(error)
                        .foregroundStyle(Color.singWordError)
                    if shouldShowRetry(uiState.errorCode) {
                        Button("重试", action: onRetry)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if uiState.isEmptyResult {
                Text("未命中词汇，请尝试切换词表")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        SongInfoCard(
                            trackName: uiState.trackName,
                            artistName: uiState.artistName,
                            provider: uiState.provider,
                            matchCount: uiState.matchedWords.count,
                            totalTokens: uiState.totalTokens,
                            isDownloaded: isDownloaded,
                            onDownload: onDownload
                        )

                        Text("命中词汇 (\(uiState.matchedWords.count))")
                            .font(SingWordTypography.titleMedium)
                            .foregroundStyle(.secondary)

                        ForEach(uiState.matchedWords) { word in
                            WordCard(
                                word: word,
                                isFavorite: favorites.contains(word.word),
                                onToggleFavorite: {
                                    onToggleFavorite(word)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle("搜索结果")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .background(backgroundColor.ignoresSafeArea())
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground
    }
}

func shouldShowRetry(_ code: SearchErrorCode) -> Bool {
    code == .networkError || code == .providerError
}

private struct SongInfoCard: View {
    let trackName: String
    let artistName: String
    let provider: String
    let matchCount: Int
    let totalTokens: Int
    let isDownloaded: Bool
    let onDownload: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "music.note")
                    .foregroundStyle(primaryColor)
                Text(trackName)
                    .font(SingWordTypography.titleLarge)
            }

            if !artistName.isEmpty {
                Text(artistName)
                    .font(SingWordTypography.bodyMedium)
                    .foregroundStyle(.secondary)
            }

            Text("来源：\(provider) | 共 \(totalTokens) 个单词，命中 \(matchCount) 个")
                .font(SingWordTypography.labelMedium)
                .foregroundStyle(.secondary)

            Button(action: onDownload) {
                HStack(spacing: 8) {
                    Image(systemName: isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle")
                    Text(isDownloaded ? "已收藏" : "收藏并下载")
                        .font(SingWordTypography.bodyMedium)
                }
                .foregroundStyle(primaryColor)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var surfaceColor: Color {
        colorScheme == .dark ? SingWordPalette.darkSurface : SingWordPalette.lightSurface
    }

    private var primaryColor: Color {
        colorScheme == .dark ? SingWordPalette.darkLink : SingWordPalette.lightLink
    }
}

private struct WordCard: View {
    let word: MatchedWord
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

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
            }

            Spacer(minLength: 8)

            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? Color.singWordError : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var surfaceColor: Color {
        colorScheme == .dark ? SingWordPalette.darkSurface : SingWordPalette.lightSurface
    }
}
