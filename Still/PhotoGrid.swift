import SwiftUI

public struct PhotoGrid: View {
    public let monthGroups: [MonthGroup]
    public let isSelectionMode: Bool
    public let selectedAssetIds: Set<String>
    public let library: any MediaLibrary
    public var onSelectAsset: (PhotoAsset) -> Void
    public var onOpenViewer: (PhotoAsset) -> Void
    public var onFavoriteSwipe: (PhotoAsset) -> Void
    public var onToggleMonthSelection: (MonthGroup) -> Void

    @ObservedObject private var settings = SettingsStore.shared
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var thumbnailImages: [String: CGImage] = [:]
    @State private var pinchScale: CGFloat = 1.0
    @State private var basePinchScale: CGFloat = 1.0

    public init(
        monthGroups: [MonthGroup],
        isSelectionMode: Bool,
        selectedAssetIds: Set<String>,
        library: any MediaLibrary,
        onSelectAsset: @escaping (PhotoAsset) -> Void,
        onOpenViewer: @escaping (PhotoAsset) -> Void,
        onFavoriteSwipe: @escaping (PhotoAsset) -> Void,
        onToggleMonthSelection: @escaping (MonthGroup) -> Void
    ) {
        self.monthGroups = monthGroups
        self.isSelectionMode = isSelectionMode
        self.selectedAssetIds = selectedAssetIds
        self.library = library
        self.onSelectAsset = onSelectAsset
        self.onOpenViewer = onOpenViewer
        self.onFavoriteSwipe = onFavoriteSwipe
        self.onToggleMonthSelection = onToggleMonthSelection
    }

    private var effectiveColumnCount: Int {
        var count = settings.columnCount
        if dynamicTypeSize.isAccessibilitySize {
            count = max(1, count - 1)
        }
        return count
    }

    public var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let gutter: CGFloat = 2.0
            let columns = effectiveColumnCount
            let totalGutter = gutter * CGFloat(columns - 1)
            let tileSize = max(10, (totalWidth - totalGutter) / CGFloat(columns))
            let gridColumns = Array(repeating: GridItem(.fixed(tileSize), spacing: gutter), count: columns)

            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 24, pinnedViews: [.sectionHeaders]) {
                        ForEach(monthGroups) { group in
                            Section(
                                header: MonthHeader(
                                    group: group,
                                    isSelectionMode: isSelectionMode,
                                    isAllSelected: !group.assets.isEmpty && group.assets.allSatisfy { selectedAssetIds.contains($0.id) },
                                    onToggleSelection: { onToggleMonthSelection(group) }
                                )
                            ) {
                                LazyVGrid(columns: gridColumns, spacing: gutter) {
                                    ForEach(group.assets) { asset in
                                        PhotoTile(
                                            asset: asset,
                                            isSelected: selectedAssetIds.contains(asset.id),
                                            isSelectionMode: isSelectionMode,
                                            size: tileSize,
                                            thumbnailImage: thumbnailImages[asset.id],
                                            onTap: {
                                                if isSelectionMode {
                                                    onSelectAsset(asset)
                                                } else {
                                                    onOpenViewer(asset)
                                                }
                                            },
                                            onLongPress: {
                                                onSelectAsset(asset)
                                            },
                                            onFavoriteSwipe: {
                                                onFavoriteSwipe(asset)
                                            }
                                        )
                                        .id(asset.id)
                                        .task {
                                            if thumbnailImages[asset.id] == nil {
                                                let img = await library.thumbnail(for: asset, size: CGSize(width: tileSize * 2, height: tileSize * 2))
                                                if let img {
                                                    thumbnailImages[asset.id] = img
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { scale in
                        let delta = scale / basePinchScale
                        if delta > 1.30 { // 30% pinch out -> fewer columns (zoom in)
                            if settings.columnCount > 2 {
                                settings.columnCount -= 1
                                HapticsService.shared.zoomStep()
                            }
                            basePinchScale = scale
                        } else if delta < 0.70 { // 30% pinch in -> more columns (zoom out)
                            if settings.columnCount < 4 {
                                settings.columnCount += 1
                                HapticsService.shared.zoomStep()
                            }
                            basePinchScale = scale
                        }
                    }
                    .onEnded { _ in
                        basePinchScale = 1.0
                    }
            )
        }
        .background(DesignColors.obsidian)
    }
}
