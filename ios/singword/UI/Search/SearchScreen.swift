import SwiftUI

struct SearchScreen: View {
    let query: String
    let isLoading: Bool
    let error: String?
    let recentSearches: [SongMatchSnapshot]
    let onQueryChange: (String) -> Void
    let onSubmit: () -> Void
    let onTapRecentSearch: (SongMatchSnapshot) -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundStyle(primaryColor)
                Text("SingWord")
                    .font(SingWordTypography.headlineLarge)
                    .foregroundStyle(textPrimary)
            }

            Text("输入歌名，提取高频词")
                .font(SingWordTypography.bodyMedium)
                .foregroundStyle(textSecondary)

            TextField("例如：Hotel California", text: Binding(
                get: { query },
                set: { onQueryChange($0) }
            ))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .onSubmit(onSubmit)
            .disabled(isLoading)
            .padding(14)
            .background(surfaceVariant)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: onSubmit) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(colorScheme == .dark ? SingWordPalette.darkTextPrimary : SingWordPalette.lightTextPrimary)
                    }
                    Text(isLoading ? "搜索中..." : "下一步")
                        .font(SingWordTypography.titleMedium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(colorScheme == .dark ? SingWordPalette.darkTextPrimary : SingWordPalette.lightTextPrimary)
                .background(primaryColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isLoading)

            if let error, !error.isEmpty {
                Text(error)
                    .font(SingWordTypography.bodyMedium)
                    .foregroundStyle(Color.singWordError)
            }

            if !recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("最近搜索")
                        .font(SingWordTypography.titleMedium)
                        .foregroundStyle(textSecondary)

                    ForEach(recentSearches.prefix(3)) { item in
                        Button {
                            onTapRecentSearch(item)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundStyle(primaryColor)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.trackName)
                                        .font(SingWordTypography.titleMedium)
                                        .foregroundStyle(textPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(item.artistName.isEmpty ? "离线结果" : item.artistName)
                                        .font(SingWordTypography.bodyMedium)
                                        .foregroundStyle(textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(surfaceVariant)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground
    }

    private var surfaceVariant: Color {
        colorScheme == .dark ? SingWordPalette.darkSurfaceVariant : SingWordPalette.lightSurfaceVariant
    }

    private var textPrimary: Color {
        colorScheme == .dark ? SingWordPalette.darkTextPrimary : SingWordPalette.lightTextPrimary
    }

    private var textSecondary: Color {
        colorScheme == .dark ? SingWordPalette.darkTextSecondary : SingWordPalette.lightTextSecondary
    }

    private var primaryColor: Color {
        colorScheme == .dark ? SingWordPalette.darkLink : SingWordPalette.lightLink
    }
}
