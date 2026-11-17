import Foundation

public struct ToastItem: Identifiable {
    public let id: UUID
    public let message: String
    public let actionTitle: String?
    public let action: (@MainActor () -> Void)?
    public let duration: TimeInterval

    public init(
        id: UUID = UUID(),
        message: String,
        actionTitle: String? = nil,
        action: (@MainActor () -> Void)? = nil,
        duration: TimeInterval = 3.0
    ) {
        self.id = id
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.duration = duration
    }
}
