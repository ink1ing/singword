import SwiftUI

struct LibraryImportScreen: View {
    @ObservedObject var viewModel: LibraryImportStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ImportStatusCard(progress: viewModel.progress)

                accessSection

                actionSection
            }
            .padding(16)
        }
        .background(backgroundColor.ignoresSafeArea())
        .navigationTitle("导入 Apple Music")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if !viewModel.progress.isRunning {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
        .alert("清除所有导入记录？", isPresented: $showResetConfirmation) {
            Button("清除并重新导入", role: .destructive) {
                viewModel.resetAllData()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("将清除所有已保存的导入记录和匹配结果，下次导入将从零开始重新处理所有歌曲。")
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? SingWordPalette.darkBackground : SingWordPalette.lightBackground
    }

    @ViewBuilder
    private var accessSection: some View {
        switch viewModel.accessStatus {
        case .ready(let storefront):
            InfoCard(
                title: "Apple Music 已就绪",
                message: "当前地区：\(storefront.uppercased())。将导入资料库歌曲并逐条识别歌词。"
            )
        case .needsAuthorization:
            InfoCard(
                title: "需要 Apple Music 授权",
                message: "首次导入前需要访问你的 Apple Music 资料库。"
            )
        case .denied:
            ErrorCard(message: "Apple Music 权限已被拒绝，请在系统设置中重新开启。")
        case .restricted:
            ErrorCard(message: "当前设备环境不允许访问 Apple Music 资料库。")
        case .subscriptionUnavailable:
            ErrorCard(message: "当前账号未启用可同步的 Apple Music 资料库。")
        case .regionUnavailable:
            ErrorCard(message: "当前地区信息不可用，暂时无法开始导入。")
        case .unavailable(let message):
            ErrorCard(message: message)
        }
    }

    @ViewBuilder
    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch viewModel.accessStatus {
            case .needsAuthorization:
                Button("请求 Apple Music 授权") {
                    viewModel.requestAuthorization()
                }
                .buttonStyle(.borderedProminent)
            case .ready:
                if viewModel.progress.isRunning {
                    HStack(spacing: 12) {
                        Button("暂停导入") {
                            viewModel.pauseImport()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("取消") {
                            viewModel.cancelImport()
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    HStack(spacing: 12) {
                        Button(viewModel.progress.phase == .paused ? "继续导入" : "开始导入") {
                            if viewModel.progress.phase == .paused {
                                viewModel.resumeImport()
                            } else {
                                viewModel.startImport()
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        if viewModel.progress.phase == .paused || viewModel.progress.phase == .cancelled {
                            Button("取消") {
                                viewModel.cancelImport()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            default:
                EmptyView()
            }

            if !viewModel.tracks.isEmpty {
                Text("当前已保存 \(viewModel.tracks.count) 首导入歌曲。")
                    .font(SingWordTypography.bodyMedium)
                    .foregroundStyle(.secondary)

                if !viewModel.progress.isRunning {
                    Button("清除记录并重新导入") {
                        showResetConfirmation = true
                    }
                    .font(SingWordTypography.bodyMedium)
                    .foregroundStyle(.red)
                }
            }
        }
    }
}

private struct InfoCard: View {
    let title: String
    let message: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(SingWordTypography.titleLarge)
            Text(message)
                .font(SingWordTypography.bodyMedium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var surfaceColor: Color {
        colorScheme == .dark ? SingWordPalette.darkSurface : SingWordPalette.lightSurface
    }
}

private struct ErrorCard: View {
    let message: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(message)
            .font(SingWordTypography.bodyMedium)
            .foregroundStyle(Color.singWordError)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var surfaceColor: Color {
        colorScheme == .dark ? SingWordPalette.darkSurface : SingWordPalette.lightSurface
    }
}

struct ImportStatusCard: View {
    let progress: LibraryImportProgress
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(phaseTitle)
                .font(SingWordTypography.titleLarge)

            ProgressView(value: progressValue)
                .progressViewStyle(.linear)

            Text("已处理 \(progress.processedCount) / \(max(progress.totalCount, 1))")
                .font(SingWordTypography.bodyMedium)
                .foregroundStyle(.secondary)

            Text("已匹配 \(progress.matchedCount) · 未匹配 \(progress.unmatchedCount) · 失败 \(progress.failedCount)")
                .font(SingWordTypography.labelMedium)
                .foregroundStyle(.secondary)

            if !progress.currentTrackTitle.isEmpty {
                Text("当前：\(progress.currentTrackTitle)")
                    .font(SingWordTypography.bodyMedium)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var phaseTitle: String {
        switch progress.phase {
        case .idle:
            return "准备导入"
        case .checkingAccess:
            return "正在检查 Apple Music 权限"
        case .scanningLibrary:
            return "正在扫描资料库"
        case .matchingLyrics:
            return "正在识别歌词"
        case .paused:
            return "导入已暂停"
        case .completed:
            return "导入已完成"
        case .cancelled:
            return "导入已取消"
        case .blocked:
            return "当前无法开始导入"
        }
    }

    private var progressValue: Double {
        guard progress.totalCount > 0 else { return 0 }
        return Double(progress.processedCount) / Double(progress.totalCount)
    }

    private var surfaceColor: Color {
        colorScheme == .dark ? SingWordPalette.darkSurface : SingWordPalette.lightSurface
    }
}
