import SwiftUI

public struct ViewerChrome: View {
    public let currentIndex: Int
    public let totalCount: Int
    public let isFavorite: Bool
    public var onClose: () -> Void
    public var onToggleFavorite: () -> Void
    public var onShare: () -> Void
    public var onInfo: () -> Void
    public var onDelete: () -> Void

    public init(
        currentIndex: Int,
        totalCount: Int,
        isFavorite: Bool,
        onClose: @escaping () -> Void = {},
        onToggleFavorite: @escaping () -> Void = {},
        onShare: @escaping () -> Void = {},
        onInfo: @escaping () -> Void = {},
        onDelete: @escaping () -> Void = {}
    ) {
        self.currentIndex = currentIndex
        self.totalCount = totalCount
        self.isFavorite = isFavorite
        self.onClose = onClose
        self.onToggleFavorite = onToggleFavorite
        self.onShare = onShare
        self.onInfo = onInfo
        self.onDelete = onDelete
    }

    public var body: some View {
        VStack {
            // Glass Top Pill with Close & Counter
            HStack(spacing: 16) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignColors.porcelain)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(currentIndex + 1) of \(totalCount)")
                    .font(DesignFonts.viewerCounter())
                    .foregroundColor(DesignColors.porcelain)

                Spacer()

                Color.clear
                    .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(width: 200, height: 44)
            .modifier(LiquidGlassModifier(isCapsule: true))
            .padding(.top, 16)

            Spacer()

            // Glass Bottom Capsule: Heart, Share, Info, and Trash (16pt apart)
            HStack(spacing: 24) {
                // Heart
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isFavorite ? DesignColors.destructive : DesignColors.porcelain)
                }
                .buttonStyle(.plain)

                // Share
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(DesignColors.porcelain)
                }
                .buttonStyle(.plain)

                // Info
                Button(action: onInfo) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(DesignColors.porcelain)
                }
                .buttonStyle(.plain)

                // 16 pt separator spacer before Trash (QOL-10)
                Spacer()
                    .frame(width: 16)

                // Trash (Destructive #FF453A)
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(DesignColors.destructive)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .modifier(LiquidGlassModifier(isCapsule: true))
            .padding(.bottom, 26)
        }
    }
}
