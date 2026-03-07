import SwiftUI

struct FavoritesFlowView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    let favoriteWords: Set<String>
    let onToggleFavorite: (MatchedWord) -> Void

    var body: some View {
        NavigationStack {
            FavoritesScreen(
                viewModel: viewModel,
                favoriteWords: favoriteWords,
                onToggleFavorite: onToggleFavorite
            )
        }
    }
}
