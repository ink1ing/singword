import Combine
import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [FavoriteWord] = []
    @Published private(set) var songs: [SongMatchSnapshot] = []
    @Published private(set) var downloadedSongIDs: Set<String> = []

    private let favoritesStore: FavoritesStore
    private let downloadedSongsStore: DownloadedSongsStore
    private var cancellables: Set<AnyCancellable> = []

    init(favoritesStore: FavoritesStore, downloadedSongsStore: DownloadedSongsStore) {
        self.favoritesStore = favoritesStore
        self.downloadedSongsStore = downloadedSongsStore

        favoritesStore.$favorites
            .sink { [weak self] words in
                self?.favorites = words
            }
            .store(in: &cancellables)

        downloadedSongsStore.$songs
            .sink { [weak self] songs in
                self?.songs = songs
                self?.downloadedSongIDs = Set(songs.map(\.id))
            }
            .store(in: &cancellables)

        Task {
            await favoritesStore.reload()
            await downloadedSongsStore.reload()
        }
    }

    func removeFavorite(_ word: FavoriteWord) {
        Task {
            await favoritesStore.remove(word)
        }
    }

    func removeSong(_ snapshot: SongMatchSnapshot) {
        Task {
            await downloadedSongsStore.remove(snapshot)
        }
    }

    func toggleSong(_ snapshot: SongMatchSnapshot) {
        Task {
            if downloadedSongIDs.contains(snapshot.id) {
                await downloadedSongsStore.remove(snapshot)
            } else {
                await downloadedSongsStore.save(snapshot)
            }
        }
    }
}
