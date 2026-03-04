import Foundation
import Combine

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var favorites: [FavoriteWord] = []
    @Published private(set) var favoriteWords: Set<String> = []

    private let repository: FavoriteRepository

    init(repository: FavoriteRepository) {
        self.repository = repository
        Task { await reload() }
    }

    func reload() async {
        let loadedFavorites = await repository.getAllFavorites()
        favorites = loadedFavorites
        favoriteWords = Set(loadedFavorites.map { $0.word })
    }

    func toggle(_ word: MatchedWord) async {
        if favoriteWords.contains(word.word) {
            await repository.delete(
                FavoriteWord(
                    word: word.word,
                    pos: word.pos,
                    definition: word.definition,
                    source: word.source
                )
            )
        } else {
            await repository.upsert(
                FavoriteWord(
                    word: word.word,
                    pos: word.pos,
                    definition: word.definition,
                    source: word.source
                )
            )
        }
        await reload()
    }

    func remove(_ word: FavoriteWord) async {
        await repository.delete(word)
        await reload()
    }
}
