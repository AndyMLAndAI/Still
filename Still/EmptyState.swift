import SwiftUI

public struct EmptyState: View {
    public let title: String
    public let message: String
    public let actionTitle: String?
    public let action: (() -> Void)?

    public init(
        title: String = "Nothing here yet",
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(DesignFonts.headline())
                .foregroundColor(DesignColors.porcelain)

            Text(message)
                .font(DesignFonts.body())
                .foregroundColor(DesignColors.ash)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DesignFonts.headline())
                        .foregroundColor(DesignColors.appleBlue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .modifier(LiquidGlassModifier(isCapsule: true))
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignColors.obsidian)
    }
}
