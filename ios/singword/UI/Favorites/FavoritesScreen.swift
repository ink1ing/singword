import SwiftUI

struct FavoritesScreen: View {
    @ObservedObject var viewModel: FavoritesViewModel

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if viewModel.favorites.isEmpty {
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
                .listStyle(.plain)
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
