import SwiftUI

struct FavoritesFlowView: View {
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        NavigationStack {
            FavoritesScreen(viewModel: viewModel)
        }
    }
}
