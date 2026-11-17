import SwiftUI

public struct PermissionState: View {
    public let isLimited: Bool
    public var onSelectMore: () -> Void
    public var onOpenSettings: () -> Void

    public init(
        isLimited: Bool,
        onSelectMore: @escaping () -> Void = {},
        onOpenSettings: @escaping () -> Void = {}
    ) {
        self.isLimited = isLimited
        self.onSelectMore = onSelectMore
        self.onOpenSettings = onOpenSettings
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text(isLimited ? "Limited Access" : "Photo Access Required")
                .font(DesignFonts.largeTitle())
                .foregroundColor(DesignColors.porcelain)

            Text(isLimited ? "Still has access to selected photos only." : "Still requires access to browse and manage your photo library.")
                .font(DesignFonts.body())
                .foregroundColor(DesignColors.ash)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                if isLimited {
                    Button(action: onSelectMore) {
                        Text("Select More Photos")
                            .font(DesignFonts.headline())
                            .foregroundColor(DesignColors.porcelain)
                            .frame(maxWidth: 240)
                            .padding(.vertical, 14)
                            .modifier(LiquidGlassModifier(isCapsule: true))
                    }
                    .buttonStyle(.plain)
                }

                Button(action: onOpenSettings) {
                    Text("Open Settings")
                        .font(DesignFonts.headline())
                        .foregroundColor(isLimited ? DesignColors.ash : DesignColors.porcelain)
                        .frame(maxWidth: 240)
                        .padding(.vertical, 14)
                        .modifier(LiquidGlassModifier(isCapsule: true))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignColors.obsidian)
    }
}
