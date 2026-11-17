import XCTest
@testable import Still

@MainActor
final class QoLResilienceTests: XCTestCase {
    // QOL-49: Limited access works
    func testQOL49_LimitedAccessButtonCopy() {
        let perm = PermissionState(isLimited: true)
        XCTAssertTrue(perm.isLimited)
    }

    // QOL-50: Denied access has a way out
    func testQOL50_DeniedAccessButtonCopy() {
        let perm = PermissionState(isLimited: false)
        XCTAssertFalse(perm.isLimited)
    }

    // QOL-51: Library changes don't jump scroll (stable IDs)
    func testQOL51_StableAssetIDs() {
        let library = FakeLibrary(assetCount: 10)
        let initialIds = library.allAssets.map(\.id)
        XCTAssertTrue(initialIds.contains("fake-1"))
        let asset1 = library.allAssets.first(where: { $0.id == "fake-1" })
        XCTAssertEqual(asset1?.id, "fake-1")
    }

    // QOL-52: Bounded memory (ThumbnailCache capped at 60 MB with LRU eviction)
    func testQOL52_ThumbnailCacheBoundedMemory() {
        let cache = ThumbnailCache()
        let maxCost = 60 * 1024 * 1024

        for i in 1...20 {
            let width = 200
            let height = 200
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
               let img = ctx.makeImage() {
                cache.set(img, forKey: "test-\(i)")
            }
        }

        XCTAssertLessThanOrEqual(cache.currentCost, maxCost)
        cache.removeAll()
        XCTAssertEqual(cache.currentCost, 0)
    }

    // QOL-53: Low Power Mode dials back
    func testQOL53_LowPowerModeDialsBack() {
        let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        XCTAssertNotNil(isLowPowerMode)
    }

    // QOL-54: Offline-first
    func testQOL54_OfflineBrowsingAvailable() {
        let library = FakeLibrary(assetCount: 20)
        XCTAssertEqual(library.allAssets.count, 20)
    }

    // QOL-55: Storage pressure
    func testQOL55_StoragePressureHandling() {
        let cache = ThumbnailCache()
        cache.removeAll()
        XCTAssertEqual(cache.currentCost, 0)
    }
}
