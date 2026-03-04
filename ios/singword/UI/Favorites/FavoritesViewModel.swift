import Combine
import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [FavoriteWord] = []

    private let favoritesStore: FavoritesStore
    private var cancellables: Set<AnyCancellable> = []

    init(favoritesStore: FavoritesStore) {
        self.favoritesStore = favoritesStore

        favoritesStore.$favorites
            .sink { [weak self] words in
                self?.favorites = words
            }
            .store(in: &cancellables)

        Task {
            await favoritesStore.reload()
        }
    }

    func removeFavorite(_ word: FavoriteWord) {
        Task {
            await favoritesStore.remove(word)
        }
    }
}
