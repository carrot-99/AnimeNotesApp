// SeasonListView.swift

import SwiftUI

/// クール選択画面
struct SeasonListView: View {
    private let current = AnimeSeason.current()
    private let yearGroups: [(year: Int, seasons: [AnimeSeason])]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    init() {
        // 来期の作品も登録されていることがあるため、来期まで表示する
        yearGroups = AnimeSeason.groupedByYear(through: AnimeSeason.current().next)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20, pinnedViews: [.sectionHeaders]) {
                    HStack(spacing: 12) {
                        FeaturedSeasonCard(season: current, badge: "今期")
                        FeaturedSeasonCard(season: current.next, badge: "来期")
                    }

                    ForEach(yearGroups, id: \.year) { group in
                        Section {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(AnimeSeason.Quarter.allCases, id: \.self) { quarter in
                                    let season = AnimeSeason(year: group.year, quarter: quarter)
                                    if group.seasons.contains(season) {
                                        SeasonChip(season: season, isCurrent: season == current)
                                    } else {
                                        // 未来のクールは枠だけ表示してレイアウトを揃える
                                        Color.clear.frame(height: 64)
                                    }
                                }
                            }
                        } header: {
                            Text(verbatim: "\(group.year)年")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 6)
                                .background(Color(.systemGroupedBackground))
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("クール選択")
        }
        .navigationViewStyle(.stack)
    }
}

private struct FeaturedSeasonCard: View {
    let season: AnimeSeason
    let badge: String

    var body: some View {
        NavigationLink {
            AnimeListView(season: season)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(badge)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.accentColor))
                    Spacer()
                    Image(systemName: season.quarter.systemImage)
                        .foregroundColor(.accentColor)
                }
                Text(season.displayName)
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                Text("アニメ一覧を見る")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SeasonChip: View {
    let season: AnimeSeason
    let isCurrent: Bool

    var body: some View {
        NavigationLink {
            AnimeListView(season: season)
        } label: {
            VStack(spacing: 6) {
                Image(systemName: season.quarter.systemImage)
                    .font(.subheadline)
                Text(season.quarter.label)
                    .font(.subheadline.bold())
            }
            .foregroundColor(isCurrent ? .white : .primary)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isCurrent ? Color.accentColor : Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(season.displayName))
    }
}
