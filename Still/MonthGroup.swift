import Foundation

public struct MonthGroup: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let date: Date
    public var assets: [PhotoAsset]

    public init(id: String, title: String, date: Date, assets: [PhotoAsset]) {
        self.id = id
        self.title = title
        self.date = date
        self.assets = assets
    }
}
