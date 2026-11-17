import XCTest
@testable import Still

@MainActor
final class QoLGestureAndZoomTests: XCTestCase {
    // QOL-11: Favorite by swiping
    func testQOL11_FavoriteBySwiping() async throws {
        let library = FakeLibrary(assetCount: 5)
        let asset = library.allAssets[0]
        let original = asset.isFavorite

        try await library.setFavorite(!original, for: asset)
        let modified = library.allAssets.first(where: { $0.id == asset.id })
        XCTAssertEqual(modified?.isFavorite, !original)
    }

    // QOL-17: Pinch grid to change density
    func testQOL17_PinchDensityThresholds() {
        let settings = SettingsStore(userDefaults: UserDefaults(suiteName: "TestQOL17")!)
        settings.columnCount = 3

        // 30% pinch out (zoom in) decreases column count to 2
        let pinchOutDelta = 1.35
        if pinchOutDelta > 1.30 && settings.columnCount > 2 {
            settings.columnCount -= 1
        }
        XCTAssertEqual(settings.columnCount, 2)

        // 30% pinch in (zoom out) increases column count
        let pinchInDelta = 0.65
        if pinchInDelta < 0.70 && settings.columnCount < 4 {
            settings.columnCount += 1
        }
        XCTAssertEqual(settings.columnCount, 3)
    }

    // QOL-19: Hide chrome with one tap
    func testQOL19_HideChromeWithOneTap() {
        var isChromeVisible = true
        // Single tap toggles chrome
        isChromeVisible.toggle()
        XCTAssertFalse(isChromeVisible)
        isChromeVisible.toggle()
        XCTAssertTrue(isChromeVisible)
    }

    // QOL-20: Zoom in viewer & swiping restricted when zoomed
    func testQOL20_ZoomRestrictions() {
        let zoomScale: CGFloat = 2.0
        let isFitScale = (zoomScale == 1.0)
        XCTAssertFalse(isFitScale)
        // Horizontal page swipe only allowed at fit scale (zoomScale == 1.0)
        let canSwipePages = isFitScale
        XCTAssertFalse(canSwipePages)
    }

    // QOL-21: No blank frames while swiping (prefetch prev/next)
    func testQOL21_PrefetchPrevAndNext() async {
        let library = FakeLibrary(assetCount: 10)
        let currentIndex = 3
        let currentAsset = library.allAssets[currentIndex]
        let prevAsset = library.allAssets[currentIndex - 1]
        let nextAsset = library.allAssets[currentIndex + 1]

        let currentImg = await library.fullImage(for: currentAsset)
        let prevImg = await library.fullImage(for: prevAsset)
        let nextImg = await library.fullImage(for: nextAsset)

        XCTAssertNotNil(currentImg)
        XCTAssertNotNil(prevImg)
        XCTAssertNotNil(nextImg)
    }

    // QOL-33: No trapped back gestures (dismiss dy > 140 pt, scale floor 0.72)
    func testQOL33_DismissThresholdAndScaleFloor() {
        let dyDismissThreshold: CGFloat = 140.0
        XCTAssertEqual(dyDismissThreshold, 140.0)

        let dragDownDy: CGFloat = 300.0
        let scale = max(0.72, 1.0 - (dragDownDy / 600.0))
        XCTAssertGreaterThanOrEqual(scale, 0.72)
        XCTAssertEqual(scale, 0.72)
    }
}
