//  AnimeDetailView.swift

import SwiftUI

struct AnimeDetailView: View {
    @StateObject private var viewModel: AnimeDetailViewModel
    @State private var isConfirmingReset = false

    init(anime: UserAnime, onAnimeChange: @escaping (UserAnime) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: AnimeDetailViewModel(anime: anime, onAnimeChange: onAnimeChange))
    }

    var body: some View {
        List {
            headerSection
            if viewModel.hasEpisodeInfo {
                progressSection
                episodesSection
            } else {
                Section {
                    Text("この作品の話数情報はまだありません。作品全体の視聴状況のみ記録できます。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.anime.title)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await viewModel.reload() }
        .task { await viewModel.loadIfNeeded() }
        .errorAlert($viewModel.errorMessage)
        .confirmationDialog("すべてのエピソードを未視聴に戻しますか？", isPresented: $isConfirmingReset, titleVisibility: .visible) {
            Button("未視聴に戻す", role: .destructive) {
                Task { await viewModel.markAll(.notWatched) }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.anime.title)
                    .font(.title2.bold())
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 12) {
                    Label(viewModel.anime.seasonText, systemImage: "calendar")
                    Label(viewModel.anime.episodesText, systemImage: "film")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 6)

            Picker(selection: animeStatusBinding) {
                ForEach(WatchStatus.menuOrder) { status in
                    Label(status.label, systemImage: status.systemImage).tag(status)
                }
            } label: {
                Label {
                    Text("視聴状況")
                } icon: {
                    StatusIcon(status: viewModel.anime.watchStatus, font: .body)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var progressSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(viewModel.watchedCount)")
                        .font(.title.bold().monospacedDigit())
                    Text("/ \(viewModel.episodes.count)話 視聴済")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int((viewModel.progress * 100).rounded()))%")
                        .font(.headline.monospacedDigit())
                        .foregroundColor(.green)
                }
                ProgressView(value: viewModel.progress)
                    .tint(.green)
                    .animation(.easeInOut, value: viewModel.progress)
            }
            .padding(.vertical, 4)

            Button {
                Task { await viewModel.markAll(.watched) }
            } label: {
                Label("すべて視聴済にする", systemImage: "checkmark.circle")
            }
            .disabled(viewModel.episodes.isEmpty || viewModel.watchedCount == viewModel.episodes.count)

            Button(role: .destructive) {
                isConfirmingReset = true
            } label: {
                Label("すべて未視聴に戻す", systemImage: "arrow.uturn.backward.circle")
            }
            .disabled(viewModel.episodes.allSatisfy { $0.watchStatus == .notWatched })
        } header: {
            Text("進捗")
        }
    }

    private var episodesSection: some View {
        Section {
            if viewModel.isLoading && viewModel.episodes.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            ForEach(viewModel.episodes) { episode in
                Button {
                    Task { await viewModel.toggle(episode) }
                } label: {
                    HStack(spacing: 12) {
                        StatusIcon(status: episode.watchStatus, font: .title3)
                        Text("第\(episode.episode_num)話")
                            .foregroundColor(.primary)
                        Spacer()
                        if episode.watchStatus != .notWatched {
                            Text(episode.watchStatus.label)
                                .font(.caption)
                                .foregroundColor(episode.watchStatus.color)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .contextMenu {
                    StatusMenuItems(current: episode.watchStatus) { status in
                        Task { await viewModel.setStatus(status, for: episode) }
                    }
                }
            }
        } header: {
            Text("エピソード")
        } footer: {
            Text("タップで「視聴済」と「未視聴」を切り替えます。長押しでその他の状況を選べます。全話視聴すると作品は自動的に「視聴済」になります。")
        }
    }

    private var animeStatusBinding: Binding<WatchStatus> {
        Binding(
            get: { viewModel.anime.watchStatus },
            set: { status in Task { await viewModel.setAnimeStatus(status) } }
        )
    }
}
