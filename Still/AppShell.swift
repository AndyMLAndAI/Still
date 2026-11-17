import SwiftUI

public struct AppShell: View {
    @StateObject public var library: FakeLibrary
    @StateObject private var settings = SettingsStore.shared

    @State private var selectedTab: TabItem = .library
    @State private var isSelectionMode: Bool = false
    @State private var selectedAssetIds: Set<String> = []
    @State private var viewerIndex: Int? = nil
    @State private var currentToast: ToastItem? = nil

    public init(library: FakeLibrary? = nil) {
        self._library = StateObject(wrappedValue: library ?? FakeLibrary(assetCount: 200))
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Screen Content
            Group {
                switch selectedTab {
                case .library:
                    LibraryScreen(
                        library: library,
                        isSelectionMode: $isSelectionMode,
                        selectedAssetIds: $selectedAssetIds,
                        onOpenViewer: { asset in
                            if let idx = library.allAssets.firstIndex(where: { $0.id == asset.id }) {
                                withAnimation(DesignMotion.viewerTransition) {
                                    viewerIndex = idx
                                }
                            }
                        },
                        onShowToast: { toast in
                            showToast(toast)
                        }
                    )
                case .search:
                    SearchScreen(
                        library: library,
                        onOpenViewer: { asset in
                            if let idx = library.allAssets.firstIndex(where: { $0.id == asset.id }) {
                                withAnimation(DesignMotion.viewerTransition) {
                                    viewerIndex = idx
                                }
                            }
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating Toast (112 pt above bottom, one at a time)
            if let toast = currentToast {
                VStack {
                    Spacer()
                    ToastGlass(toast: toast) {
                        withAnimation(DesignMotion.reduceMotionCrossfade) {
                            if currentToast?.id == toast.id {
                                currentToast = nil
                            }
                        }
                    }
                    .padding(.bottom, 112)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            }

            // Bottom Chrome: TabBarGlass or SelectionBar
            VStack {
                Spacer()
                if isSelectionMode {
                    SelectionBar(
                        selectedCount: selectedAssetIds.count,
                        totalCount: library.allAssets.count,
                        onShare: {
                            // Share action
                        },
                        onFavorite: {
                            toggleFavoriteForSelected()
                        },
                        onDelete: {
                            deleteSelected()
                        },
                        onToggleSelectAll: {
                            toggleSelectAll()
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 26)
                } else {
                    TabBarGlass(selectedTab: $selectedTab) { tab in
                        // Tapping active tab scrolls to top (QOL-31)
                        NotificationCenter.default.post(name: NSNotification.Name("ScrollToTop"), object: tab)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 26)
                }
            }
            .zIndex(5)

            // Full Screen Photo Viewer
            if let index = viewerIndex {
                PhotoViewer(
                    assets: library.allAssets,
                    currentIndex: Binding(
                        get: { index },
                        set: { viewerIndex = $0 }
                    ),
                    library: library,
                    onClose: {
                        withAnimation(DesignMotion.viewerTransition) {
                            viewerIndex = nil
                        }
                    },
                    onToggleFavorite: { asset in
                        toggleFavorite(for: asset)
                    },
                    onDelete: { asset in
                        deleteSingle(asset)
                    },
                    onShare: { asset in
                        // Share single
                    }
                )
                .transition(.identity)
                .zIndex(20)
            }
        }
        .background(DesignColors.obsidian.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .onAppear {
            if let tab = TabItem(rawValue: settings.selectedTab) {
                selectedTab = tab
            }
        }
        .onChange(of: selectedTab) { newTab in
            settings.selectedTab = newTab.rawValue
        }
    }

    private func showToast(_ toast: ToastItem) {
        withAnimation(DesignMotion.toastTransition) {
            currentToast = toast
        }
    }

    private func toggleSelectAll() {
        if selectedAssetIds.count == library.allAssets.count {
            selectedAssetIds.removeAll()
        } else {
            selectedAssetIds = Set(library.allAssets.map(\.id))
        }
        HapticsService.shared.selection()
    }

    private func toggleFavoriteForSelected() {
        let selected = library.allAssets.filter { selectedAssetIds.contains($0.id) }
        Task { @MainActor in
            for asset in selected {
                try? await library.setFavorite(!asset.isFavorite, for: asset)
            }
            HapticsService.shared.favorite()
            showToast(ToastItem(message: "Updated Favorites", duration: 3.0))
        }
    }

    private func deleteSelected() {
        let toDelete = library.allAssets.filter { selectedAssetIds.contains($0.id) }
        Task { @MainActor in
            try? await library.delete(assets: toDelete)
            selectedAssetIds.removeAll()
            isSelectionMode = false
            HapticsService.shared.delete()
            // PhotoKit delete confirmation result (QOL-07)
            showToast(ToastItem(message: "Moved to Recently Deleted", actionTitle: "Open", action: {}, duration: 4.0))
        }
    }

    private func toggleFavorite(for asset: PhotoAsset) {
        let newState = !asset.isFavorite
        Task { @MainActor in
            try? await library.setFavorite(newState, for: asset)
            HapticsService.shared.favorite()
            showToast(
                ToastItem(
                    message: newState ? "Favorite" : "Unfavorite",
                    actionTitle: "Undo",
                    action: {
                        Task { @MainActor in
                            try? await self.library.setFavorite(!newState, for: asset)
                        }
                    },
                    duration: 3.0
                )
            )
        }
    }

    private func deleteSingle(_ asset: PhotoAsset) {
        Task { @MainActor in
            try? await library.delete(assets: [asset])
            viewerIndex = nil
            HapticsService.shared.delete()
            showToast(ToastItem(message: "Moved to Recently Deleted", actionTitle: "Open", action: {}, duration: 4.0))
        }
    }
}
