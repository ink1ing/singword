import Combine
import Foundation
import MusicKit

@MainActor
final class LibraryImportStore: ObservableObject {
    @Published private(set) var tracks: [ImportedTrack] = []
    @Published private(set) var matches: [String: ImportedTrackMatch] = [:]
    @Published private(set) var progress: LibraryImportProgress = .idle
    @Published private(set) var accessStatus: LibraryAccessStatus = .needsAuthorization
    @Published var importScreenPresented: Bool = false

    private let importRepository: AppleMusicImportRepository
    private let stateRepository: LibraryImportStateRepository
    private let coordinator: LibraryImportCoordinator
    private var importTask: Task<Void, Never>?

    init(
        importRepository: AppleMusicImportRepository,
        stateRepository: LibraryImportStateRepository,
        coordinator: LibraryImportCoordinator
    ) {
        self.importRepository = importRepository
        self.stateRepository = stateRepository
        self.coordinator = coordinator

        Task {
            await loadFromDisk()
            await refreshAccessStatus()
        }
    }

    var groupedTracks: [(String, [ImportedTrack])] {
        let inProgress = tracks.filter { $0.status == .queued || $0.status == .matchingLyrics }
        let matched = tracks.filter { $0.status == .matched }
        let unmatched = tracks.filter { $0.status == .unmatched }
        let failed = tracks.filter { $0.status == .failed || $0.status == .cancelled }

        return [
            ("进行中", inProgress),
            ("已匹配", matched),
            ("未匹配", unmatched),
            ("失败", failed)
        ].filter { !$0.1.isEmpty }
    }

    func loadFromDisk() async {
        tracks = await importRepository.getAllTracks()
        matches = Dictionary(uniqueKeysWithValues: await importRepository.getAllMatches().map { ($0.trackID, $0) })
        let storedProgress = await stateRepository.load()
        if storedProgress.isRunning {
            progress = LibraryImportProgress(
                phase: .paused,
                totalCount: storedProgress.totalCount,
                queuedCount: storedProgress.queuedCount,
                processedCount: storedProgress.processedCount,
                matchedCount: storedProgress.matchedCount,
                unmatchedCount: storedProgress.unmatchedCount,
                failedCount: storedProgress.failedCount,
                currentTrackTitle: "",
                isRunning: false
            )
            await stateRepository.save(progress)
        } else {
            progress = storedProgress
        }
    }

    func refreshAccessStatus() async {
        accessStatus = await coordinator.currentAccessStatus()
    }

    func requestAuthorization() {
        Task {
            accessStatus = await coordinator.requestAccessStatus()
        }
    }

    func startImport() {
        guard !progress.isRunning else { return }
        importTask?.cancel()
        importTask = Task { [weak self] in
            await self?.runImport(resumeExisting: shouldResumeExistingQueue, specificTrackIDs: nil)
        }
    }

    func pauseImport() {
        guard progress.isRunning else { return }
        importTask?.cancel()
        importTask = nil

        tracks = tracks.map { track in
            if track.status == .matchingLyrics {
                return track.updating(status: .queued, failureReason: nil, failureMessage: "")
            }
            return track
        }

        Task {
            await importRepository.replaceTracks(tracks)
        }

        updateProgress(phase: .paused, isRunning: false, currentTrackTitle: "")
    }

    func resumeImport() {
        guard !progress.isRunning else { return }
        importTask?.cancel()
        importTask = Task { [weak self] in
            await self?.runImport(resumeExisting: true, specificTrackIDs: nil)
        }
    }

    func cancelImport() {
        guard progress.isRunning || progress.phase == .paused else { return }
        importTask?.cancel()
        importTask = nil

        tracks = tracks.map { track in
            if track.status == .queued || track.status == .matchingLyrics {
                return track.updating(
                    status: .cancelled,
                    failureReason: .cancelled,
                    failureMessage: "导入已取消"
                )
            }
            return track
        }

        Task {
            await importRepository.replaceTracks(tracks)
        }

        updateProgress(phase: .cancelled, isRunning: false, currentTrackTitle: "")
    }

    func retry(_ track: ImportedTrack) {
        guard !progress.isRunning else { return }
        tracks = tracks.map { item in
            guard item.id == track.id else { return item }
            return item.updating(status: .queued, failureReason: nil, failureMessage: "")
        }
        Task {
            await importRepository.replaceTracks(tracks)
        }
        importTask?.cancel()
        importTask = Task { [weak self] in
            await self?.runImport(resumeExisting: true, specificTrackIDs: [track.id])
        }
    }

    func match(for trackID: String) -> ImportedTrackMatch? {
        matches[trackID]
    }

    private var shouldResumeExistingQueue: Bool {
        tracks.contains { track in
            track.status == .queued ||
                track.status == .matchingLyrics ||
                (track.status == .failed && track.failureReason == .networkFailed)
        }
    }

    private func runImport(resumeExisting: Bool, specificTrackIDs: Set<String>?) async {
        let access = await coordinator.currentAccessStatus()
        accessStatus = access

        guard case let .ready(storefront) = access else {
            updateProgress(phase: .blocked, isRunning: false, currentTrackTitle: "")
            return
        }

        if !resumeExisting || tracks.isEmpty {
            updateProgress(phase: .scanningLibrary, isRunning: true, currentTrackTitle: "")

            do {
                let existingTracks = await importRepository.getAllTracks()
                let existingMatches = await importRepository.getAllMatches()
                let songs = try await coordinator.fetchAllLibrarySongs { [weak self] fetchedCount, _ in
                    Task { @MainActor in
                        guard let self else { return }
                        self.progress = LibraryImportProgress(
                            phase: .scanningLibrary,
                            totalCount: fetchedCount,
                            queuedCount: fetchedCount,
                            processedCount: 0,
                            matchedCount: 0,
                            unmatchedCount: 0,
                            failedCount: 0,
                            currentTrackTitle: "",
                            isRunning: true
                        )
                    }
                }

                let mergedTracks = coordinator.mergeImportedTracks(
                    songs: songs,
                    existingTracks: existingTracks,
                    existingMatches: existingMatches,
                    storefront: storefront
                )
                let scannedIDs = Set(mergedTracks.map(\.id))
                tracks = mergedTracks
                matches = Dictionary(
                    uniqueKeysWithValues: existingMatches
                        .filter { scannedIDs.contains($0.trackID) }
                        .map { ($0.trackID, $0) }
                )
                await importRepository.replaceTracks(mergedTracks)
                await importRepository.prune(toTrackIDs: scannedIDs)
            } catch {
                updateProgress(phase: .blocked, isRunning: false, currentTrackTitle: "")
                return
            }
        }

        let queue = tracks.filter { track in
            if let specificTrackIDs {
                return specificTrackIDs.contains(track.id)
            }

            if track.status == .queued || track.status == .matchingLyrics {
                return true
            }

            return track.status == .failed && track.failureReason == .networkFailed
        }

        if queue.isEmpty {
            finalizeCompletedImport()
            return
        }

        queue.forEach { track in
            setTrack(track.updating(status: .matchingLyrics, failureReason: nil, failureMessage: ""))
        }

        updateProgress(
            phase: .matchingLyrics,
            isRunning: true,
            currentTrackTitle: queue.first?.title ?? ""
        )

        var nextIndex = 0

        await withTaskGroup(of: ImportedTrackProcessingResult.self) { group in
            for _ in 0..<2 {
                if nextIndex < queue.count {
                    let next = queue[nextIndex]
                    nextIndex += 1
                    group.addTask { [coordinator] in
                        await coordinator.processTrack(next)
                    }
                }
            }

            while let result = await group.next() {
                if Task.isCancelled {
                    group.cancelAll()
                    break
                }

                setTrack(result.track)
                if let match = result.match {
                    matches[match.trackID] = match
                    await importRepository.upsertMatch(match)
                } else {
                    matches.removeValue(forKey: result.track.id)
                    await importRepository.removeMatch(trackID: result.track.id)
                }

                await importRepository.upsertTrack(result.track)
                updateProgress(
                    phase: .matchingLyrics,
                    isRunning: true,
                    currentTrackTitle: nextIndex < queue.count ? queue[nextIndex].title : ""
                )

                if nextIndex < queue.count {
                    let next = queue[nextIndex]
                    nextIndex += 1
                    let matchingTrack = next.updating(status: .matchingLyrics, failureReason: nil, failureMessage: "")
                    setTrack(matchingTrack)
                    await importRepository.upsertTrack(matchingTrack)
                    group.addTask { [coordinator] in
                        await coordinator.processTrack(next)
                    }
                }
            }
        }

        if Task.isCancelled {
            return
        }

        finalizeCompletedImport()
    }

    private func finalizeCompletedImport() {
        updateProgress(phase: .completed, isRunning: false, currentTrackTitle: "")
        importScreenPresented = false
        importTask = nil
    }

    private func setTrack(_ track: ImportedTrack) {
        tracks.removeAll { $0.id == track.id }
        tracks.append(track)
        tracks.sort { lhs, rhs in
            if lhs.status == rhs.status {
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            return lhs.importedAt > rhs.importedAt
        }
    }

    private func updateProgress(
        phase: LibraryImportPhase,
        isRunning: Bool,
        currentTrackTitle: String
    ) {
        let queued = tracks.count { $0.status == .queued || $0.status == .matchingLyrics }
        let matched = tracks.count { $0.status == .matched }
        let unmatched = tracks.count { $0.status == .unmatched }
        let failed = tracks.count { $0.status == .failed }
        let processed = matched + unmatched + failed

        progress = LibraryImportProgress(
            phase: phase,
            totalCount: tracks.count,
            queuedCount: queued,
            processedCount: processed,
            matchedCount: matched,
            unmatchedCount: unmatched,
            failedCount: failed,
            currentTrackTitle: currentTrackTitle,
            isRunning: isRunning
        )

        Task {
            await stateRepository.save(progress)
        }
    }
}

private extension Array {
    func count(where predicate: (Element) -> Bool) -> Int {
        reduce(into: 0) { count, element in
            if predicate(element) {
                count += 1
            }
        }
    }
}
