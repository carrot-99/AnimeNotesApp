//  AnimeCollectionViewModel.swift

import Foundation

/// 作品一覧を表示する画面（クール別・検索・ステータス別）の共通処理
@MainActor
class AnimeCollectionViewModel: ObservableObject {
    @Published var animes: [UserAnime] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let animeService: AnimeDataServiceProtocol

    init(animeService: AnimeDataServiceProtocol = AnimeDataService()) {
        self.animeService = animeService
    }

    /// 視聴状況を変更する。画面には即座に反映し、保存に失敗したら元に戻す。
    func setStatus(_ status: WatchStatus, for anime: UserAnime) async {
        guard anime.watchStatus != status, anime.user_id != UserAnime.guestUserId else { return }
        let snapshot = animes
        var updated = anime
        updated.watchStatus = status
        apply(updated)
        Haptics.selection()

        do {
            try await animeService.save(updated)
        } catch {
            animes = snapshot
            errorMessage = error.userMessage
        }
    }

    /// 詳細画面など他の画面での変更を一覧に反映する
    func apply(_ anime: UserAnime) {
        if let index = animes.firstIndex(where: { $0.id == anime.id }) {
            animes[index] = anime
        }
    }

    /// 読み込み処理を共通のローディング・エラー表示付きで実行する
    func load(_ operation: () async throws -> [UserAnime]) async {
        isLoading = true
        defer { isLoading = false }
        do {
            animes = try await operation()
        } catch is CancellationError {
            // 画面遷移などでキャンセルされた場合は何もしない
        } catch {
            errorMessage = error.userMessage
        }
    }
}
