import SwiftUI

public struct SearchScreen: View {
    @ObservedObject public var library: FakeLibrary
    public var onOpenViewer: (PhotoAsset) -> Void

    @ObservedObject private var settings = SettingsStore.shared
    @State private var query: String = ""
    @State private var selectedChipIds: Set<String> = []
    @State private var thumbnailImages: [String: CGImage] = [:]

    public init(library: FakeLibrary, onOpenViewer: @escaping (PhotoAsset) -> Void = { _ in }) {
        self.library = library
        self.onOpenViewer = onOpenViewer
    }

    private var availableChips: [SearchChip] {
        [
            SearchChip(id: "place-tokyo", title: "Tokyo", category: "place"),
            SearchChip(id: "place-paris", title: "Paris", category: "place"),
            SearchChip(id: "place-bigsur", title: "Big Sur", category: "place"),
            SearchChip(id: "tag-coast", title: "Coast", category: "subject"),
            SearchChip(id: "tag-mountain", title: "Mountain", category: "subject"),
            SearchChip(id: "tag-night", title: "Night", category: "subject"),
            SearchChip(id: "month-october", title: "October", category: "month"),
            SearchChip(id: "month-september", title: "September", category: "month")
        ]
    }

    public var searchResults: [SearchResultItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let selectedChips = availableChips.filter { selectedChipIds.contains($0.id) }

        if trimmed.isEmpty && selectedChips.isEmpty {
            return []
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"

        return library.allAssets.compactMap { asset -> SearchResultItem? in
            var matchReason: String?

            // 1. Text Query Filter (matches place, tags, or month name)
            if !trimmed.isEmpty {
                let monthName = dateFormatter.string(from: asset.creationDate).lowercased()
                if asset.place.lowercased().contains(trimmed) {
                    matchReason = asset.place
                } else if let matchedTag = asset.tags.first(where: { $0.lowercased().contains(trimmed) }) {
                    matchReason = matchedTag
                } else if monthName.contains(trimmed) {
                    matchReason = dateFormatter.string(from: asset.creationDate)
                } else {
                    return nil // Did not match text query
                }
            }

            // 2. Chip Filters combined with AND (QOL-36)
            for chip in selectedChips {
                switch chip.category {
                case "place":
                    if asset.place.caseInsensitiveCompare(chip.title) != .orderedSame {
                        return nil
                    }
                    if matchReason == nil { matchReason = chip.title }
                case "subject":
                    if !asset.tags.contains(where: { $0.caseInsensitiveCompare(chip.title) == .orderedSame }) {
                        return nil
                    }
                    if matchReason == nil { matchReason = chip.title }
                case "month":
                    let monthStr = dateFormatter.string(from: asset.creationDate)
                    if monthStr.caseInsensitiveCompare(chip.title) != .orderedSame {
                        return nil
                    }
                    if matchReason == nil { matchReason = chip.title }
                default:
                    break
                }
            }

            return SearchResultItem(asset: asset, matchLabel: matchReason ?? asset.place)
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Large Title
            HStack {
                Text("Search")
                    .font(DesignFonts.largeTitle())
                    .tracking(-0.022 * 34)
                    .foregroundColor(DesignColors.porcelain)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Search Field
            SearchField(text: $query) {
                settings.addRecentSearch(query)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            // Filter Chips
            SearchChips(chips: availableChips, selectedChipIds: $selectedChipIds)
                .padding(.bottom, 16)

            // Content Area
            if query.isEmpty && selectedChipIds.isEmpty {
                if !settings.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Searches")
                                .font(DesignFonts.caption())
                                .foregroundColor(DesignColors.ash)
                            Spacer()
                            Button("Clear") {
                                settings.clearRecentSearches()
                            }
                            .font(DesignFonts.caption())
                            .foregroundColor(DesignColors.appleBlue)
                        }
                        .padding(.horizontal, 16)

                        ForEach(settings.recentSearches, id: \.self) { search in
                            Button {
                                query = search
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(DesignColors.ash)
                                    Text(search)
                                        .font(DesignFonts.body())
                                        .foregroundColor(DesignColors.porcelain)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                } else {
                    EmptyState(
                        title: "Search Photos",
                        message: "Search by place, subject, or select filters above."
                    )
                }
            } else {
                let results = searchResults
                if results.isEmpty {
                    EmptyState(
                        title: "Nothing here yet",
                        message: "No photos matched your search criteria."
                    )
                } else {
                    GeometryReader { geo in
                        let gutter: CGFloat = 2.0
                        let columns = 3
                        let totalGutter = gutter * CGFloat(columns - 1)
                        let tileSize = (geo.size.width - totalGutter) / CGFloat(columns)
                        let gridColumns = Array(repeating: GridItem(.fixed(tileSize), spacing: gutter), count: columns)

                        ScrollView {
                            LazyVGrid(columns: gridColumns, spacing: gutter) {
                                ForEach(results) { item in
                                    ZStack(alignment: .bottomLeading) {
                                        PhotoTile(
                                            asset: item.asset,
                                            size: tileSize,
                                            thumbnailImage: thumbnailImages[item.asset.id],
                                            onTap: {
                                                settings.addRecentSearch(query)
                                                onOpenViewer(item.asset)
                                            }
                                        )

                                        // Match label (QOL-38)
                                        Text(item.matchLabel)
                                            .font(DesignFonts.caption())
                                            .foregroundColor(DesignColors.porcelain)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(DesignColors.obsidian.opacity(0.8))
                                            .padding(4)
                                    }
                                    .task {
                                        if thumbnailImages[item.asset.id] == nil {
                                            let img = await library.thumbnail(for: item.asset, size: CGSize(width: tileSize * 2, height: tileSize * 2))
                                            if let img {
                                                thumbnailImages[item.asset.id] = img
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 120)
                        }
                    }
                }
            }
        }
        .background(DesignColors.obsidian)
    }
}
