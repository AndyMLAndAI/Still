import SwiftUI

public struct LiquidGlassModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    public var cornerRadius: CGFloat?
    public var isCapsule: Bool

    public init(cornerRadius: CGFloat? = nil, isCapsule: Bool = false) {
        self.cornerRadius = cornerRadius
        self.isCapsule = isCapsule
    }

    public func body(content: Content) -> some View {
        let hairline = colorSchemeContrast == .increased ? 2.0 : 1.0

        if reduceTransparency {
            if isCapsule {
                content
                    .background(
                        Capsule()
                            .fill(DesignColors.graphite)
                            .overlay(Capsule().stroke(DesignColors.steel, lineWidth: hairline))
                    )
            } else {
                let radius = cornerRadius ?? 0
                content
                    .background(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(DesignColors.graphite)
                            .overlay(
                                RoundedRectangle(cornerRadius: radius, style: .continuous)
                                    .stroke(DesignColors.steel, lineWidth: hairline)
                            )
                    )
            }
        } else {
            if isCapsule {
                content
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            stops: [
                                                .init(color: Color.white.opacity(0.40), location: 0.0),
                                                .init(color: Color.white.opacity(0.12), location: 0.4),
                                                .init(color: Color.white.opacity(0.04), location: 1.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: hairline
                                    )
                            )
                    )
            } else {
                let radius = cornerRadius ?? 0
                content
                    .background(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: radius, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            stops: [
                                                .init(color: Color.white.opacity(0.40), location: 0.0),
                                                .init(color: Color.white.opacity(0.12), location: 0.4),
                                                .init(color: Color.white.opacity(0.04), location: 1.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: hairline
                                    )
                            )
                    )
            }
        }
    }
}
