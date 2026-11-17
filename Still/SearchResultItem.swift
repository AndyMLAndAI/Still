import Foundation

public struct SearchResultItem: Identifiable, Hashable, Sendable {
    public let asset: PhotoAsset
    public let matchLabel: String

    public var id: String { asset.id }

    public init(asset: PhotoAsset, matchLabel: String) {
        self.asset = asset
        self.matchLabel = matchLabel
    }
}
