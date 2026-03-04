import SwiftUI

private enum SearchRoute: Hashable {
    case candidates
    case result
}

struct SearchFlowView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var path: [SearchRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            SearchScreen(
                query: viewModel.uiState.query,
                isLoading: viewModel.uiState.isLoading,
                error: viewModel.uiState.error,
                onQueryChange: {
                    viewModel.onQueryChanged($0)
                    viewModel.clearError()
                },
                onSubmit: {
                    if viewModel.uiState.isLoading {
                        return
                    }
                    if viewModel.searchCandidates() {
                        path = [.candidates]
                    }
                }
            )
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SearchRoute.self) { route in
                switch route {
                case .candidates:
                    SongCandidatesScreen(
                        uiState: viewModel.uiState,
                        onRetry: {
                            _ = viewModel.searchCandidates()
                        },
                        onSelect: { candidate in
                            viewModel.selectCandidate(candidate)
                            path.append(.result)
                        }
                    )
                case .result:
                    ResultScreen(
                        uiState: viewModel.uiState,
                        favorites: viewModel.favoriteWords,
                        onToggleFavorite: { word in
                            viewModel.toggleFavorite(word)
                        },
                        onRetry: {
                            viewModel.retryResult()
                        }
                    )
                }
            }
        }
    }
}
