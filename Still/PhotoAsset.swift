import Foundation

public struct PhotoAsset: Identifiable, Hashable, Sendable {
    public let id: String
    public let creationDate: Date
    public let place: String
    public let tags: [String]
    public var isFavorite: Bool
    public let fileSizeBytes: Int64
    public let aspectRatio: Double
    public var isCloudPlaceholder: Bool

    public init(
        id: String,
        creationDate: Date,
        place: String,
        tags: [String] = [],
        isFavorite: Bool = false,
        fileSizeBytes: Int64 = 2_400_000,
        aspectRatio: Double = 1.0,
        isCloudPlaceholder: Bool = false
    ) {
        self.id = id
        self.creationDate = creationDate
        self.place = place
        self.tags = tags
        self.isFavorite = isFavorite
        self.fileSizeBytes = fileSizeBytes
        self.aspectRatio = aspectRatio
        self.isCloudPlaceholder = isCloudPlaceholder
    }
}
