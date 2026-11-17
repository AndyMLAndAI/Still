import SwiftUI

public struct PhotoTile: View {
    public let asset: PhotoAsset
    public let isSelected: Bool
    public let isSelectionMode: Bool
    public let size: CGFloat
    public let thumbnailImage: CGImage?
    public var onTap: () -> Void
    public var onLongPress: () -> Void
    public var onFavoriteSwipe: () -> Void

    @State private var dragOffset: CGFloat = 0

    public init(
        asset: PhotoAsset,
        isSelected: Bool = false,
        isSelectionMode: Bool = false,
        size: CGFloat,
        thumbnailImage: CGImage? = nil,
        onTap: @escaping () -> Void = {},
        onLongPress: @escaping () -> Void = {},
        onFavoriteSwipe: @escaping () -> Void = {}
    ) {
        self.asset = asset
        self.isSelected = isSelected
        self.isSelectionMode = isSelectionMode
        self.size = size
        self.thumbnailImage = thumbnailImage
        self.onTap = onTap
        self.onLongPress = onLongPress
        self.onFavoriteSwipe = onFavoriteSwipe
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            // Base Square Tile: Corner Radius 0!
            Group {
                if let cgImage = thumbnailImage {
                    Image(decorative: cgImage, scale: 2.0)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(DesignColors.graphite)
                        .frame(width: size, height: size)
                }
            }
            .contentShape(Rectangle())

            // Favorite Heart Indicator (Bottom-Left)
            if asset.isFavorite {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(DesignColors.destructive)
                            .padding(6)
                        Spacer()
                    }
                }
            }

            // Selection Checkmark (Top-Right)
            if isSelectionMode {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(DesignColors.appleBlue)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DesignColors.white)
                    } else {
                        Circle()
                            .stroke(DesignColors.porcelain.opacity(0.8), lineWidth: 1.5)
                            .background(Circle().fill(Color.black.opacity(0.2)))
                            .frame(width: 22, height: 22)
                    }
                }
                .padding(6)
            }
        }
        .frame(width: size, height: size)
        .offset(x: dragOffset)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    if !isSelectionMode && value.translation.width > 0 {
                        dragOffset = min(40, value.translation.width)
                    }
                }
                .onEnded { value in
                    if !isSelectionMode && value.translation.width > 30 {
                        onFavoriteSwipe()
                    }
                    withAnimation(DesignMotion.springTap) {
                        dragOffset = 0
                    }
                }
        )
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.45)
                .onEnded { _ in
                    onLongPress()
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    onTap()
                }
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : [.isButton])
    }

    private var accessibilityDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: asset.creationDate)
        let favStr = asset.isFavorite ? "Favorite" : "Not favorite"
        return "\(asset.place), \(dateStr), \(favStr)"
    }
}
