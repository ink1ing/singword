import Combine
import Foundation

enum SearchErrorCode {
    case none
    case emptyQuery
    case noWordbookSelected
    case wordbookMissingAsset
    case wordbookParseError
    case lyricsNotFound
    case networkError
    case providerError
    case unknown
}

struct SearchUiState {
    var query: String = ""
    var isLoading: Bool = false
    var trackName: String = ""
    var artistName: String = ""
    var provider: String = ""
    var candidates: [LyricsCandidate] = []
    var selectedCandidate: LyricsCandidate?
    var matchedWords: [MatchedWord] = []
    var totalTokens: Int = 0
    var isEmptyResult: Bool = false
    var error: String?
    var errorCode: SearchErrorCode = .none
}

@MainActor
final class SearchViewModel: ObservableObject {
    @Published private(set) var uiState = SearchUiState()
    @Published private(set) var favoriteWords: Set<String> = []

    private let lyricsRepository: LyricsRepository
    private let wordbookRepository: WordbookRepository
    private let settingsRepository: SettingsRepository
    private let favoritesStore: FavoritesStore
    private var cancellables: Set<AnyCancellable> = []
    private var activeTask: Task<Void, Never>?

    init(
        lyricsRepository: LyricsRepository,
        wordbookRepository: WordbookRepository,
        settingsRepository: SettingsRepository,
        favoritesStore: FavoritesStore
    ) {
        self.lyricsRepository = lyricsRepository
        self.wordbookRepository = wordbookRepository
        self.settingsRepository = settingsRepository
        self.favoritesStore = favoritesStore

        favoritesStore.$favoriteWords
            .sink { [weak self] words in
                self?.favoriteWords = words
            }
            .store(in: &cancellables)
    }

    func onQueryChanged(_ query: String) {
        uiState.query = query
    }

    func searchCandidates() -> Bool {
        let query = uiState.query.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            setError(message: "请输入歌名", code: .emptyQuery)
            return false
        }

        if settingsRepository.getEnabledWordbooks().isEmpty {
            setError(message: "请先在设置中选择至少一个词表", code: .noWordbookSelected)
            return false
        }

        resetForNewSearch()

        runOperation { [self] in
            switch await lyricsRepository.searchCandidates(query, limit: 5) {
            case .success(let candidates, let provider):
                guard !Task.isCancelled else { return }
                uiState.isLoading = false
                uiState.provider = provider
                uiState.candidates = candidates
                uiState.error = nil
                uiState.errorCode = .none

            case .notFound:
                guard !Task.isCancelled else { return }
                setError(message: "未找到歌词", code: .lyricsNotFound)

            case .networkError(let message):
                guard !Task.isCancelled else { return }
                setError(message: message, code: .networkError)

            case .providerError(_, let message):
                guard !Task.isCancelled else { return }
                setError(message: message, code: .providerError)
            }
        }

        return true
    }

    func selectCandidate(_ candidate: LyricsCandidate) {
        runOperation { [self] in
            await matchCandidate(candidate)
        }
    }

    func search() {
        let query = uiState.query.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            setError(message: "请输入歌名", code: .emptyQuery)
            return
        }

        resetForNewSearch()

        runOperation { [self] in
            switch await lyricsRepository.searchLyrics(query) {
            case .success(let trackName, let artistName, let lyrics, let provider):
                guard !Task.isCancelled else { return }
                await matchCandidate(
                    LyricsCandidate(
                        trackName: trackName,
                        artistName: artistName,
                        lyrics: lyrics,
                        provider: provider
                    )
                )

            case .notFound:
                guard !Task.isCancelled else { return }
                setError(message: "未找到歌词", code: .lyricsNotFound)

            case .networkError(let message):
                guard !Task.isCancelled else { return }
                setError(message: message, code: .networkError)

            case .providerError(_, let message):
                guard !Task.isCancelled else { return }
                setError(message: message, code: .providerError)
            }
        }
    }

    func retryResult() {
        if let selected = uiState.selectedCandidate {
            selectCandidate(selected)
        } else {
            search()
        }
    }

    func clearError() {
        uiState.error = nil
        uiState.errorCode = .none
    }

    func toggleFavorite(_ word: MatchedWord) {
        Task {
            await favoritesStore.toggle(word)
        }
    }

    private func loadEnabledWordbooksOrError() async -> [String: (WordEntry, String)]? {
        let enabled = settingsRepository.getEnabledWordbooks()
        if enabled.isEmpty {
            setError(message: "请先在设置中选择至少一个词表", code: .noWordbookSelected)
            return nil
        }

        switch await wordbookRepository.loadEnabledWordbooks(enabled: enabled) {
        case .success(let words):
            return words

        case .missingAsset(let assetPath):
            setError(message: "词表文件缺失：\(assetPath)", code: .wordbookMissingAsset)
            return nil

        case .parseError(let assetPath, _):
            setError(message: "词表解析失败：\(assetPath)", code: .wordbookParseError)
            return nil
        }
    }

    private func matchCandidate(_ candidate: LyricsCandidate) async {
        guard !Task.isCancelled else { return }
        uiState.isLoading = true
        uiState.trackName = candidate.trackName
        uiState.artistName = candidate.artistName
        uiState.provider = candidate.provider
        uiState.selectedCandidate = candidate
        uiState.matchedWords = []
        uiState.totalTokens = 0
        uiState.isEmptyResult = false
        uiState.error = nil
        uiState.errorCode = .none

        guard let wordbooks = await loadEnabledWordbooksOrError() else {
            guard !Task.isCancelled else { return }
            uiState.isLoading = false
            return
        }

        guard !Task.isCancelled else { return }
        let tokens = LyricsProcessor.tokenize(candidate.lyrics)
        let matchedWords = VocabMatcher.match(tokens: tokens, wordbooks: wordbooks)

        guard !Task.isCancelled else { return }
        uiState.isLoading = false
        uiState.trackName = candidate.trackName
        uiState.artistName = candidate.artistName
        uiState.provider = candidate.provider
        uiState.selectedCandidate = candidate
        uiState.matchedWords = matchedWords
        uiState.totalTokens = tokens.count
        uiState.isEmptyResult = matchedWords.isEmpty
        uiState.error = nil
        uiState.errorCode = .none
    }

    private func resetForNewSearch() {
        uiState.isLoading = true
        uiState.trackName = ""
        uiState.artistName = ""
        uiState.provider = ""
        uiState.candidates = []
        uiState.selectedCandidate = nil
        uiState.matchedWords = []
        uiState.totalTokens = 0
        uiState.isEmptyResult = false
        uiState.error = nil
        uiState.errorCode = .none
    }

    private func setError(message: String, code: SearchErrorCode) {
        uiState.isLoading = false
        uiState.error = message
        uiState.errorCode = code
    }

    private func runOperation(_ operation: @escaping () async -> Void) {
        activeTask?.cancel()
        activeTask = Task { [weak self] in
            guard self != nil else { return }
            await operation()
        }
    }
}
