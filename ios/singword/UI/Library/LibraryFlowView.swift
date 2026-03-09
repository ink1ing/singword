import SwiftUI

struct LibraryFlowView: View {
    @ObservedObject var viewModel: LibraryImportStore
    let favoriteWords: Set<String>
    let onToggleFavorite: (MatchedWord) -> Void

    var body: some View {
        NavigationStack {
            LibraryListScreen(
                viewModel: viewModel,
                favoriteWords: favoriteWords,
                onToggleFavorite: onToggleFavorite
            )
            .sheet(isPresented: $viewModel.importScreenPresented) {
                NavigationStack {
                    LibraryImportScreen(viewModel: viewModel)
                }
            }
        }
    }
}
