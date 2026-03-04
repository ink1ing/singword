import SwiftUI

struct SettingsFlowView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            SettingsScreen(viewModel: viewModel)
        }
    }
}
