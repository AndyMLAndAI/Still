import Foundation
import CoreGraphics

@MainActor
public protocol MediaLibrary: AnyObject, Sendable {
    var allAssets: [PhotoAsset] { get }
    var monthGroups: [MonthGroup] { get }
    
    func refresh() async
    func thumbnail(for asset: PhotoAsset, size: CGSize) async -> CGImage?
    func fullImage(for asset: PhotoAsset) async -> CGImage?
    func setFavorite(_ isFavorite: Bool, for asset: PhotoAsset) async throws
    func delete(assets: [PhotoAsset]) async throws
}
