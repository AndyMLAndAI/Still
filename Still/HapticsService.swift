import UIKit

@MainActor
public final class HapticsService {
    public static let shared = HapticsService()

    public var isEnabled: Bool = true

    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    public init() {
        selectionFeedback.prepare()
        lightImpact.prepare()
        mediumImpact.prepare()
    }

    public func selection() {
        guard isEnabled else { return }
        selectionFeedback.selectionChanged()
    }

    public func tick() {
        guard isEnabled else { return }
        lightImpact.impactOccurred(intensity: 0.7)
    }

    public func zoomStep() {
        guard isEnabled else { return }
        lightImpact.impactOccurred(intensity: 0.8)
    }

    public func delete() {
        guard isEnabled else { return }
        mediumImpact.impactOccurred(intensity: 1.0)
    }

    public func favorite() {
        guard isEnabled else { return }
        notificationFeedback.notificationOccurred(.success)
    }
}
