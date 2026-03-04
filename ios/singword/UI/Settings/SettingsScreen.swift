import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Form {
            Section {
                Picker("主题", selection: Binding(
                    get: { viewModel.uiState.themeMode },
                    set: { viewModel.setThemeMode($0) }
                )) {
                    ForEach(AppThemeMode.allCases, id: \.self) { mode in
                        Text(mode.title)
                            .font(SingWordTypography.bodyMedium)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(surfaceColor)
            } header: {
                Text("主题模式")
                    .font(SingWordTypography.labelMedium)
            }

            Section {
                WordbookToggleRow(
                    title: "CET-4",
                    enabled: viewModel.uiState.selection[.cet4] == true,
                    onToggle: { viewModel.toggle(.cet4) }
                )
                .listRowBackground(surfaceColor)
                WordbookToggleRow(
                    title: "CET-6",
                    enabled: viewModel.uiState.selection[.cet6] == true,
                    onToggle: { viewModel.toggle(.cet6) }
                )
                .listRowBackground(surfaceColor)
                WordbookToggleRow(
                    title: "IELTS",
                    enabled: viewModel.uiState.selection[.ielts] == true,
                    onToggle: { viewModel.toggle(.ielts) }
                )
                .listRowBackground(surfaceColor)
                WordbookToggleRow(
                    title: "TOEFL",
                    enabled: viewModel.uiState.selection[.toefl] == true,
                    onToggle: { viewModel.toggle(.toefl) }
                )
                .listRowBackground(surfaceColor)
            } header: {
                Text("词表")
                    .font(SingWordTypography.labelMedium)
            }

            Section {
                NavigationLink {
                    AboutSingWordScreen()
                } label: {
                    Text("关于 SingWord")
                        .font(SingWordTypography.bodyMedium)
                }
                .listRowBackground(surfaceColor)
            } header: {
                Text("关于")
                    .font(SingWordTypography.labelMedium)
            }

            if let warning = viewModel.uiState.warning, !warning.isEmpty {
                Section {
                    Text(warning)
                        .font(SingWordTypography.bodyMedium)
                        .foregroundStyle(Color.singWordError)
                        .listRowBackground(surfaceColor)
                }
            }
        }
        .font(SingWordTypography.bodyMedium)
        .scrollContentBackground(.hidden)
        .background(backgroundColor.ignoresSafeArea())
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground
    }

    private var surfaceColor: Color {
        colorScheme == .dark ? SingWordPalette.darkSurface : SingWordPalette.lightSurface
    }
}

private struct WordbookToggleRow: View {
    let title: String
    let enabled: Bool
    let onToggle: () -> Void

    var body: some View {
        Toggle(isOn: Binding(
            get: { enabled },
            set: { _ in onToggle() }
        )) {
            Text(title)
                .font(SingWordTypography.bodyMedium)
        }
    }
}
