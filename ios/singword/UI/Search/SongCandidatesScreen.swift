import SwiftUI

struct SongCandidatesScreen: View {
    let uiState: SearchUiState
    let onRetry: () -> Void
    let onSelect: (LyricsCandidate) -> Void

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
            } else if uiState.candidates.isEmpty {
                Text("没有可选结果，请尝试更完整的歌名")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("为“\(uiState.query.trimmingCharacters(in: .whitespacesAndNewlines))”找到最多 5 条结果，请选择最匹配的一首")
                            .font(SingWordTypography.bodyMedium)
                            .foregroundStyle(.secondary)

                        ForEach(Array(uiState.candidates.enumerated()), id: \.offset) { _, candidate in
                            CandidateCard(candidate: candidate) {
                                onSelect(candidate)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle("选择歌曲")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .background(backgroundColor.ignoresSafeArea())
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground
    }
}

private struct CandidateCard: View {
    let candidate: LyricsCandidate
    let onSelect: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "music.note")
                    .foregroundStyle(primaryColor)
                Text(candidate.trackName)
                    .font(SingWordTypography.titleMedium)
                    .fontWeight(.semibold)
            }

            if !candidate.artistName.isEmpty {
                Text(candidate.artistName)
                    .font(SingWordTypography.bodyMedium)
                    .foregroundStyle(.secondary)
            }

            Text("来源：\(candidate.provider)")
                .font(SingWordTypography.labelMedium)
                .foregroundStyle(.secondary)

            Button(action: onSelect) {
                Text("选择并校对")
                    .font(SingWordTypography.titleMedium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(colorScheme == .dark ? SingWordPalette.darkTextPrimary : SingWordPalette.lightTextPrimary)
                    .background(primaryColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
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
