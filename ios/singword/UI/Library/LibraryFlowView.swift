import SwiftUI

struct LibraryFlowView: View {
    @ObservedObject var viewModel: LibraryImportStore
    let favoriteWords: Set<String>
    let downloadedSongIDs: Set<String>
    let onToggleFavorite: (MatchedWord) -> Void
    let onToggleSongFavorite: (SongMatchSnapshot) -> Void

    var body: some View {
        NavigationStack {
            LibraryListScreen(
                viewModel: viewModel,
                favoriteWords: favoriteWords,
                downloadedSongIDs: downloadedSongIDs,
                onToggleFavorite: onToggleFavorite,
                onToggleSongFavorite: onToggleSongFavorite
            )
            .sheet(isPresented: $viewModel.importScreenPresented) {
                NavigationStack {
                    LibraryImportScreen(viewModel: viewModel)
                }
            }
        }
    }
}
