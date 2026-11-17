import Foundation
import CoreGraphics
import UIKit

@MainActor
public final class FakeLibrary: ObservableObject, MediaLibrary {
    @Published public private(set) var allAssets: [PhotoAsset] = []
    @Published public private(set) var monthGroups: [MonthGroup] = []

    private let imageCache = ThumbnailCache.shared

    public init(assetCount: Int = 200) {
        populate(count: assetCount)
    }

    public func populate(count: Int) {
        var generated: [PhotoAsset] = []
        let calendar = Calendar.current
        
        let places = ["Big Sur", "Tokyo", "Reykjavik", "Paris", "Yosemite", "Kyoto", "Venice", "Zion"]
        let tagsPool = ["Coast", "Architecture", "Mountain", "Night", "Street", "Forest", "Water", "Sky"]

        // Anchor dates across August, September, October 2026
        var components = DateComponents()
        components.year = 2026
        components.day = 15
        components.hour = 12

        let months = [10, 9, 8] // Most recent first

        var currentId = 1
        for month in months {
            components.month = month
            let baseDate = calendar.date(from: components) ?? Date()
            let countForMonth = count / months.count

            for i in 0..<countForMonth {
                let dayOffset = Double(i % 28)
                let date = baseDate.addingTimeInterval(dayOffset * 86400)
                let place = places[(currentId + i) % places.count]
                let tag1 = tagsPool[(currentId * 2 + i) % tagsPool.count]
                let tag2 = tagsPool[(currentId * 3 + i) % tagsPool.count]
                let isFav = (currentId % 7 == 0)

                let asset = PhotoAsset(
                    id: "fake-\(currentId)",
                    creationDate: date,
                    place: place,
                    tags: [tag1, tag2],
                    isFavorite: isFav,
                    fileSizeBytes: Int64(1_800_000 + (currentId * 150_000) % 6_000_000),
                    aspectRatio: (currentId % 5 == 0) ? 1.33 : ((currentId % 3 == 0) ? 0.75 : 1.0),
                    isCloudPlaceholder: (currentId % 23 == 0)
                )
                generated.append(asset)
                currentId += 1
            }
        }

        // Sort descending by creation date
        self.allAssets = generated.sorted(by: { $0.creationDate > $1.creationDate })
        self.monthGroups = buildMonthGroups(from: self.allAssets)
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

    public func refresh() async {
        self.monthGroups = buildMonthGroups(from: self.allAssets)
    }

    public func thumbnail(for asset: PhotoAsset, size: CGSize) async -> CGImage? {
        let cacheKey = "thumb-\(asset.id)-\(Int(size.width))x\(Int(size.height))"
        if let cached = imageCache.get(forKey: cacheKey) {
            return cached
        }

        let img = generateDeterministicImage(for: asset, size: size)
        if let img {
            imageCache.set(img, forKey: cacheKey)
        }
        return img
    }

    public func fullImage(for asset: PhotoAsset) async -> CGImage? {
        let fullSize = CGSize(width: 1200, height: 1200 / asset.aspectRatio)
        return await thumbnail(for: asset, size: fullSize)
    }

    public func setFavorite(_ isFavorite: Bool, for asset: PhotoAsset) async throws {
        if let idx = allAssets.firstIndex(where: { $0.id == asset.id }) {
            allAssets[idx].isFavorite = isFavorite
        }
        for gIdx in monthGroups.indices {
            if let aIdx = monthGroups[gIdx].assets.firstIndex(where: { $0.id == asset.id }) {
                monthGroups[gIdx].assets[aIdx].isFavorite = isFavorite
            }
        }
    }

    public func delete(assets toDelete: [PhotoAsset]) async throws {
        let idsToDelete = Set(toDelete.map(\.id))
        allAssets.removeAll(where: { idsToDelete.contains($0.id) })
        for gIdx in monthGroups.indices {
            monthGroups[gIdx].assets.removeAll(where: { idsToDelete.contains($0.id) })
        }
        monthGroups.removeAll(where: { $0.assets.isEmpty })
    }

    private func generateDeterministicImage(for asset: PhotoAsset, size: CGSize) -> CGImage? {
        let width = max(1, Int(size.width))
        let height = max(1, Int(size.height))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        // Generate deterministic colors from hash
        let hash = UInt32(truncatingIfNeeded: asset.id.hashValue)
        let r = CGFloat((hash & 0xFF)) / 255.0 * 0.45 + 0.15
        let g = CGFloat(((hash >> 8) & 0xFF)) / 255.0 * 0.45 + 0.15
        let b = CGFloat(((hash >> 16) & 0xFF)) / 255.0 * 0.45 + 0.15

        context.setFillColor(red: r, green: g, blue: b, alpha: 1.0)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw a subtle geometric diagonal band
        context.setFillColor(red: min(1.0, r + 0.12), green: min(1.0, g + 0.12), blue: min(1.0, b + 0.12), alpha: 0.8)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: CGFloat(height)))
        path.addLine(to: CGPoint(x: CGFloat(width), y: 0))
        path.addLine(to: CGPoint(x: CGFloat(width), y: CGFloat(height) * 0.4))
        path.addLine(to: CGPoint(x: CGFloat(width) * 0.4, y: CGFloat(height)))
        path.closeSubpath()
        context.addPath(path)
        context.fillPath()

        return context.makeImage()
    }
}
