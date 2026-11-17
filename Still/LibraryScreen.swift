import SwiftUI

public struct LibraryScreen: View {
    @ObservedObject public var library: FakeLibrary
    @Binding public var isSelectionMode: Bool
    @Binding public var selectedAssetIds: Set<String>
    public var onOpenViewer: (PhotoAsset) -> Void
    public var onShowToast: (ToastItem) -> Void

    @State private var lastTappedAssetIndex: Int?
    @State private var previouslySelectedIds: Set<String> = []

    public init(
        library: FakeLibrary,
        isSelectionMode: Binding<Bool>,
        selectedAssetIds: Binding<Set<String>>,
        onOpenViewer: @escaping (PhotoAsset) -> Void,
        onShowToast: @escaping (ToastItem) -> Void
    ) {
        self.library = library
        self._isSelectionMode = isSelectionMode
        self._selectedAssetIds = selectedAssetIds
        self.onOpenViewer = onOpenViewer
        self.onShowToast = onShowToast
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack(alignment: .firstTextBaseline) {
                Text("Library")
                    .font(DesignFonts.largeTitle())
                    .tracking(-0.022 * 34)
                    .foregroundColor(DesignColors.porcelain)

                Spacer()

                Button {
                    withAnimation(DesignMotion.springTap) {
                        if isSelectionMode {
                            // Accidental Cancel recovery (QOL-05)
                            let current = selectedAssetIds
                            previouslySelectedIds = current
                            selectedAssetIds.removeAll()
                            isSelectionMode = false

                            if !current.isEmpty {
                                onShowToast(
                                    ToastItem(
                                        message: "Selection cleared",
                                        actionTitle: "Undo",
                                        action: {
                                            self.selectedAssetIds = self.previouslySelectedIds
                                            self.isSelectionMode = true
                                        },
                                        duration: 5.0
                                    )
                                )
                            }
                        } else {
                            isSelectionMode = true
                        }
                    }
                } label: {
                    Text(isSelectionMode ? "Cancel" : "Select")
                        .font(DesignFonts.headline())
                        .foregroundColor(DesignColors.porcelain)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(DesignColors.obsidian)

            // Photo Grid edge to edge
            if library.allAssets.isEmpty {
                EmptyState(
                    title: "Nothing here yet",
                    message: "Photos added to your library will appear here."
                )
            } else {
                PhotoGrid(
                    monthGroups: library.monthGroups,
                    isSelectionMode: isSelectionMode,
                    selectedAssetIds: selectedAssetIds,
                    library: library,
                    onSelectAsset: { asset in
                        handleAssetSelection(asset)
                    },
                    onOpenViewer: { asset in
                        onOpenViewer(asset)
                    },
                    onFavoriteSwipe: { asset in
                        toggleFavorite(for: asset)
                    },
                    onToggleMonthSelection: { group in
                        toggleMonthSelection(group)
                    }
                )
            }
        }
        .background(DesignColors.obsidian)
    }

    private func handleAssetSelection(_ asset: PhotoAsset) {
        if !isSelectionMode {
            withAnimation(DesignMotion.springTap) {
                isSelectionMode = true
            }
        }

        let all = library.allAssets
        guard let currentIndex = all.firstIndex(where: { $0.id == asset.id }) else { return }

        // Range select with two taps (QOL-03)
        if let lastIdx = lastTappedAssetIndex, selectedAssetIds.count >= 1 && !selectedAssetIds.contains(asset.id) {
            let start = min(lastIdx, currentIndex)
            let end = max(lastIdx, currentIndex)
            for i in start...end {
                selectedAssetIds.insert(all[i].id)
            }
            HapticsService.shared.selection()
            lastTappedAssetIndex = currentIndex
            return
        }

        if selectedAssetIds.contains(asset.id) {
            selectedAssetIds.remove(asset.id)
            if selectedAssetIds.isEmpty {
                lastTappedAssetIndex = nil
            }
        } else {
            selectedAssetIds.insert(asset.id)
            lastTappedAssetIndex = currentIndex
        }
        HapticsService.shared.selection()
    }

    private func toggleMonthSelection(_ group: MonthGroup) {
        let groupIds = group.assets.map(\.id)
        let allContained = groupIds.allSatisfy { selectedAssetIds.contains($0) }
        withAnimation(DesignMotion.springTap) {
            if allContained {
                for id in groupIds {
                    selectedAssetIds.remove(id)
                }
            } else {
                for id in groupIds {
                    selectedAssetIds.insert(id)
                }
            }
        }
        HapticsService.shared.selection()
    }

    private func toggleFavorite(for asset: PhotoAsset) {
        let newState = !asset.isFavorite
        Task { @MainActor in
            try? await library.setFavorite(newState, for: asset)
            HapticsService.shared.favorite()
            onShowToast(
                ToastItem(
                    message: newState ? "Favorite" : "Unfavorite",
                    actionTitle: "Undo",
                    action: {
                        Task { @MainActor in
                            try? await self.library.setFavorite(!newState, for: asset)
                        }
                    },
                    duration: DesignMotion.toastDuration
                )
            )
        }
    }
}
