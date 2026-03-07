import Foundation
import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
final class RecentSearchStore: ObservableObject {
    @Published private(set) var items: [SongMatchSnapshot] = []

    private let repository: RecentSearchRepository

    init(repository: RecentSearchRepository) {
        self.repository = repository
        Task { await reload() }
    }

    func reload() async {
        items = await repository.getAll()
    }

    func record(_ snapshot: SongMatchSnapshot) async {
        await repository.upsert(snapshot)
        await reload()
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: SingWordShared.widgetKind)
        #endif
    }
}
