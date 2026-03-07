import Foundation
import Combine

@MainActor
final class DownloadedSongsStore: ObservableObject {
    @Published private(set) var songs: [SongMatchSnapshot] = []
    @Published private(set) var songIDs: Set<String> = []

    private let repository: DownloadedSongRepository

    init(repository: DownloadedSongRepository) {
        self.repository = repository
        Task { await reload() }
    }

    func reload() async {
        let loadedSongs = await repository.getAll()
        songs = loadedSongs
        songIDs = Set(loadedSongs.map(\.id))
    }

    func save(_ snapshot: SongMatchSnapshot) async {
        await repository.upsert(snapshot)
        await reload()
    }

    func remove(_ snapshot: SongMatchSnapshot) async {
        await repository.delete(snapshot)
        await reload()
    }
}
