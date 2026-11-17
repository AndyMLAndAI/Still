import SwiftUI

public struct ToastGlass: View {
    public let toast: ToastItem
    public var onDismiss: () -> Void

    public init(toast: ToastItem, onDismiss: @escaping () -> Void = {}) {
        self.toast = toast
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: 16) {
            Text(toast.message)
                .font(DesignFonts.toastText())
                .foregroundColor(DesignColors.porcelain)
                .lineLimit(1)

            if let actionTitle = toast.actionTitle, let action = toast.action {
                Button {
                    action()
                    onDismiss()
                } label: {
                    Text(actionTitle)
                        .font(DesignFonts.toastAction())
                        .foregroundColor(DesignColors.appleBlue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .modifier(LiquidGlassModifier(isCapsule: true))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                withAnimation(DesignMotion.reduceMotionCrossfade) {
                    onDismiss()
                }
            }
        }
    }
}
