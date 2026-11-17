import SwiftUI

public struct PhotoViewer: View {
    public let assets: [PhotoAsset]
    @Binding public var currentIndex: Int
    public let library: any MediaLibrary
    public var onClose: () -> Void
    public var onToggleFavorite: (PhotoAsset) -> Void
    public var onDelete: (PhotoAsset) -> Void
    public var onShare: (PhotoAsset) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isChromeVisible: Bool = true
    @State private var dragOffset: CGSize = .zero
    @State private var zoomScale: CGFloat = 1.0
    @State private var showInfoSheet: Bool = false
    @State private var showHeartBurst: Bool = false
    @State private var currentImage: CGImage?
    @State private var prefetchedImages: [String: CGImage] = [:]

    public init(
        assets: [PhotoAsset],
        currentIndex: Binding<Int>,
        library: any MediaLibrary,
        onClose: @escaping () -> Void = {},
        onToggleFavorite: @escaping (PhotoAsset) -> Void = { _ in },
        onDelete: @escaping (PhotoAsset) -> Void = { _ in },
        onShare: @escaping (PhotoAsset) -> Void = { _ in }
    ) {
        self.assets = assets
        self._currentIndex = currentIndex
        self.library = library
        self.onClose = onClose
        self.onToggleFavorite = onToggleFavorite
        self.onDelete = onDelete
        self.onShare = onShare
    }

    private var currentAsset: PhotoAsset? {
        guard currentIndex >= 0 && currentIndex < assets.count else { return nil }
        return assets[currentIndex]
    }

    public var body: some View {
        ZStack {
            // Pure black canvas
            DesignColors.obsidian
                .ignoresSafeArea()
                .opacity(backgroundOpacity)

            // Full-screen photo (Square / sharp corners: corner radius 0)
            if let asset = currentAsset {
                Group {
                    if let img = currentImage {
                        Image(decorative: img, scale: 1.0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Rectangle()
                            .fill(DesignColors.graphite)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .scaleEffect(effectiveImageScale)
                .offset(dragOffset)
                // Tap toggles chrome (QOL-19)
                .onTapGesture(count: 1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isChromeVisible.toggle()
                    }
                }
                // Double tap sets Favorite and triggers heart burst (0.85s)
                .onTapGesture(count: 2) {
                    if !asset.isFavorite {
                        onToggleFavorite(asset)
                        if !reduceMotion {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showHeartBurst = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + DesignMotion.heartBurstDuration) {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showHeartBurst = false
                                }
                            }
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard zoomScale == 1.0 else { return }
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            guard zoomScale == 1.0 else { return }
                            let dx = value.translation.width
                            let dy = value.translation.height

                            // Downward drag dismiss when dy > 140 pt
                            if dy > 140 {
                                onClose()
                                return
                            }

                            // Horizontal swipe change when dx > 70 pt
                            if dx > 70 && currentIndex > 0 {
                                withAnimation(DesignMotion.springTap) {
                                    currentIndex -= 1
                                }
                            } else if dx < -70 && currentIndex < assets.count - 1 {
                                withAnimation(DesignMotion.springTap) {
                                    currentIndex += 1
                                }
                            }

                            withAnimation(DesignMotion.springTap) {
                                dragOffset = .zero
                            }
                        }
                )
                .task(id: currentIndex) {
                    await loadAndPrefetch()
                }
            }

            // Heart Burst Overlay (0.85 s)
            if showHeartBurst {
                Image(systemName: "heart.fill")
                    .font(.system(size: 96))
                    .foregroundColor(DesignColors.destructive)
                    .shadow(radius: 0)
                    .transition(.scale.combined(with: .opacity))
            }

            // Floating Chrome
            if isChromeVisible, let asset = currentAsset {
                ViewerChrome(
                    currentIndex: currentIndex,
                    totalCount: assets.count,
                    isFavorite: asset.isFavorite,
                    onClose: onClose,
                    onToggleFavorite: {
                        onToggleFavorite(asset)
                    },
                    onShare: {
                        onShare(asset)
                    },
                    onInfo: {
                        withAnimation(DesignMotion.springTap) {
                            showInfoSheet = true
                        }
                    },
                    onDelete: {
                        onDelete(asset)
                    }
                )
                .transition(.opacity)
            }

            // Info Sheet Overlay
            if showInfoSheet, let asset = currentAsset {
                VStack {
                    Spacer()
                    InfoSheet(asset: asset) {
                        withAnimation(DesignMotion.springTap) {
                            showInfoSheet = false
                        }
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .statusBarHidden(!isChromeVisible)
    }

    private var backgroundOpacity: Double {
        if dragOffset.height > 0 {
            let progress = Double(min(1.0, dragOffset.height / 300.0))
            return max(0.2, 1.0 - progress)
        }
        return 1.0
    }

    private var effectiveImageScale: CGFloat {
        if dragOffset.height > 0 {
            // Scale floor is 0.72 during downward drag
            let scale = 1.0 - (dragOffset.height / 600.0)
            return max(0.72, scale)
        }
        return zoomScale
    }

    private func loadAndPrefetch() async {
        guard let current = currentAsset else { return }
        // 1. Set full image
        let img = await library.fullImage(for: current)
        self.currentImage = img

        // 2. Prefetch prev and next full image (QOL-21)
        if currentIndex > 0 {
            let prev = assets[currentIndex - 1]
            Task {
                _ = await library.fullImage(for: prev)
            }
        }
        if currentIndex < assets.count - 1 {
            let next = assets[currentIndex + 1]
            Task {
                _ = await library.fullImage(for: next)
            }
        }
    }
}
