//  AnimeDetailViewModel.swift

import Foundation

@MainActor
final class AnimeDetailViewModel: ObservableObject {
    @Published private(set) var anime: UserAnime
    @Published private(set) var episodes: [UserEpisode] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    /// 作品の視聴状況が変わったときに呼ばれる（一覧画面への反映用）
    private let onAnimeChange: (UserAnime) -> Void
    private let animeService: AnimeDataServiceProtocol
    private let episodeService: EpisodeDataServiceProtocol
    private var hasLoaded = false
    /// 作品の視聴履歴ドキュメントが Firestore に存在するか
    private var isHistorySaved: Bool

    init(
        anime: UserAnime,
        animeService: AnimeDataServiceProtocol = AnimeDataService(),
        episodeService: EpisodeDataServiceProtocol = EpisodeDataService(),
        onAnimeChange: @escaping (UserAnime) -> Void = { _ in }
    ) {
        self.anime = anime
        self.animeService = animeService
        self.episodeService = episodeService
        self.onAnimeChange = onAnimeChange
        // 未視聴以外の作品は視聴履歴から読み込まれたもの
        self.isHistorySaved = anime.watchStatus != .notWatched
    }

    var watchedCount: Int {
        episodes.filter { $0.watchStatus == .watched }.count
    }

    var progress: Double {
        episodes.isEmpty ? 0 : Double(watchedCount) / Double(episodes.count)
    }

    var hasEpisodeInfo: Bool {
        (anime.episodes ?? 0) > 0
    }

    // MARK: - 読み込み

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await reload()
    }

    /// 話数分のエピソードを並べ、記録済みのものは保存された状況を反映する
    func reload() async {
        guard let count = anime.episodes, count > 0 else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let saved = try await episodeService.fetchEpisodes(userId: anime.user_id, animeId: anime.anime_id)
            let savedByNumber = Dictionary(saved.map { ($0.episode_num, $0) }, uniquingKeysWith: { first, _ in first })
            episodes = (1...count).map { number in
                savedByNumber[number]
                    ?? UserEpisode(userId: anime.user_id, animeId: anime.anime_id, episodeNumber: number)
            }
            hasLoaded = true
        } catch is CancellationError {
        } catch {
            errorMessage = error.userMessage
        }
    }

    // MARK: - 作品の視聴状況

    func setAnimeStatus(_ status: WatchStatus) async {
        guard status != anime.watchStatus else { return }
        let previous = anime
        anime.watchStatus = status
        Haptics.selection()
        do {
            try await animeService.save(anime)
            isHistorySaved = true
            onAnimeChange(anime)
        } catch {
            anime = previous
            errorMessage = error.userMessage
        }
    }

    // MARK: - エピソードの視聴状況

    /// タップ時: 視聴済 ⇔ 未視聴 を切り替える
    func toggle(_ episode: UserEpisode) async {
        await setStatus(episode.watchStatus == .watched ? .notWatched : .watched, for: [episode])
    }

    func setStatus(_ status: WatchStatus, for episode: UserEpisode) async {
        await setStatus(status, for: [episode])
    }

    func markAll(_ status: WatchStatus) async {
        await setStatus(status, for: episodes)
        if status == .watched {
            Haptics.success()
        }
    }

    private func setStatus(_ status: WatchStatus, for targets: [UserEpisode]) async {
        let changed = targets
            .filter { $0.watchStatus != status }
            .map { episode -> UserEpisode in
                var updated = episode
                updated.watchStatus = status
                return updated
            }
        guard !changed.isEmpty else { return }

        let snapshot = episodes
        for episode in changed {
            if let index = episodes.firstIndex(where: { $0.id == episode.id }) {
                episodes[index] = episode
            }
        }
        if changed.count == 1 {
            Haptics.selection()
        }

        do {
            // 作品の視聴履歴ドキュメントがないとアカウント削除時にエピソード履歴を辿れないため、先に作成しておく
            if !isHistorySaved {
                try await animeService.save(anime)
                isHistorySaved = true
            }
            try await episodeService.save(changed)
            await syncAnimeStatus(afterMarking: status)
        } catch {
            episodes = snapshot
            errorMessage = error.userMessage
        }
    }

    /// エピソードの進み具合に合わせて作品の視聴状況を自動更新する
    private func syncAnimeStatus(afterMarking status: WatchStatus) async {
        guard !episodes.isEmpty else { return }
        let target: WatchStatus?
        if watchedCount == episodes.count {
            target = .watched
        } else if status == .watched, [.notWatched, .planned].contains(anime.watchStatus) {
            // 見始めたら「視聴中」へ
            target = .watching
        } else if status != .watched, anime.watchStatus == .watched {
            // 視聴済の作品で未視聴の話が出たら「視聴中」へ戻す
            target = .watching
        } else {
            target = nil
        }
        if let target {
            await setAnimeStatus(target)
        }
    }
}
