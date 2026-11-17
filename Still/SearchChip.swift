import Foundation

public struct SearchChip: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let category: String

    public init(id: String, title: String, category: String) {
        self.id = id
        self.title = title
        self.category = category
    }
}
