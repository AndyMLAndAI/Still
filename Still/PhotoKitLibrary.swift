import Foundation
import CoreGraphics
import Photos
import UIKit

@MainActor
public final class PhotoKitLibrary: ObservableObject, MediaLibrary {
    @Published public private(set) var allAssets: [PhotoAsset] = []
    @Published public private(set) var monthGroups: [MonthGroup] = []
    @Published public private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined

    private let imageManager = PHCachingImageManager.default()
    private var phAssetMap: [String: PHAsset] = [:]

    public init() {
        self.authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    public func requestAuthorization() async -> PHAuthorizationStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        self.authorizationStatus = status
        if status == .authorized || status == .limited {
            await refresh()
        }
        return status
    }

    public func refresh() async {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let results = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var converted: [PhotoAsset] = []
        var map: [String: PHAsset] = [:]

        results.enumerateObjects { phAsset, _, _ in
            let id = phAsset.localIdentifier
            map[id] = phAsset

            let asset = PhotoAsset(
                id: id,
                creationDate: phAsset.creationDate ?? Date(),
                place: phAsset.location != nil ? "Location" : "Photo",
                tags: [],
                isFavorite: phAsset.isFavorite,
                fileSizeBytes: 2_500_000,
                aspectRatio: Double(phAsset.pixelWidth) / max(1.0, Double(phAsset.pixelHeight)),
                isCloudPlaceholder: false
            )
            converted.append(asset)
        }

        self.phAssetMap = map
        self.allAssets = converted
        self.monthGroups = buildMonthGroups(from: converted)
    }

    private func buildMonthGroups(from assets: [PhotoAsset]) -> [MonthGroup] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy"

        let grouped = Dictionary(grouping: assets) { asset -> String in
            let comp = calendar.dateComponents([.year, .month], from: asset.creationDate)
            return String(format: "%04d-%02d", comp.year ?? 2026, comp.month ?? 1)
        }

        let sortedKeys = grouped.keys.sorted(by: >)
        return sortedKeys.compactMap { key in
            guard let groupAssets = grouped[key], !groupAssets.isEmpty else { return nil }
            let firstDate = groupAssets[0].creationDate
            let title = dateFormatter.string(from: firstDate)
            return MonthGroup(
                id: key,
                title: title,
                date: firstDate,
                assets: groupAssets.sorted(by: { $0.creationDate > $1.creationDate })
            )
        }
    }

    public func thumbnail(for asset: PhotoAsset, size: CGSize) async -> CGImage? {
        guard let phAsset = phAssetMap[asset.id] else { return nil }

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false

        return await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: phAsset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { uiImage, _ in
                continuation.resume(returning: uiImage?.cgImage)
            }
        }
    }

    public func fullImage(for asset: PhotoAsset) async -> CGImage? {
        guard let phAsset = phAssetMap[asset.id] else { return nil }

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false

        return await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: phAsset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { uiImage, _ in
                continuation.resume(returning: uiImage?.cgImage)
            }
        }
    }

    public func setFavorite(_ isFavorite: Bool, for asset: PhotoAsset) async throws {
        guard let phAsset = phAssetMap[asset.id] else { return }

        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest(for: phAsset)
            request.isFavorite = isFavorite
        }
        await refresh()
    }

    public func delete(assets toDelete: [PhotoAsset]) async throws {
        let phAssets = toDelete.compactMap { phAssetMap[$0.id] }
        guard !phAssets.isEmpty else { return }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(phAssets as NSArray)
        }
        await refresh()
    }
}
