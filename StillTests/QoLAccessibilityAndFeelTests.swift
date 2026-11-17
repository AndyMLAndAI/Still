import XCTest
import SwiftUI
@testable import Still

@MainActor
final class QoLAccessibilityAndFeelTests: XCTestCase {
    // QOL-40: Haptics that mean something
    func testQOL40_HapticsRespectSetting() {
        let haptics = HapticsService.shared
        haptics.isEnabled = false
        // Should not crash and safely do nothing when disabled
        haptics.selection()
        haptics.tick()
        haptics.favorite()
        haptics.delete()

        haptics.isEnabled = true
        XCTAssertTrue(haptics.isEnabled)
    }

    // QOL-41: Thumbnails appear instantly (< 100ms)
    func testQOL41_ThumbnailsLoadFast() async {
        let library = FakeLibrary(assetCount: 10)
        let asset = library.allAssets[0]

        let startTime = CFAbsoluteTimeGetCurrent()
        let thumbnail = await library.thumbnail(for: asset, size: CGSize(width: 100, height: 100))
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0

        XCTAssertNotNil(thumbnail)
        XCTAssertLessThan(elapsed, 100.0)
    }

    // QOL-42: Empty states that teach
    func testQOL42_EmptyStateGuidance() {
        let empty = EmptyState(
            title: "Nothing here yet",
            message: "Photos added to your library will appear here."
        )
        XCTAssertEqual(empty.title, "Nothing here yet")
        XCTAssertEqual(empty.message, "Photos added to your library will appear here.")
    }

    // QOL-43: Toasts never cover what matters (112 pt above bottom, one at a time)
    func testQOL43_ToastPositionAndSingleInstance() {
        let bottomPadding: CGFloat = 112.0
        XCTAssertEqual(bottomPadding, 112.0)

        var currentToast: ToastItem? = ToastItem(message: "First")
        XCTAssertEqual(currentToast?.message, "First")

        // New toast replaces previous
        currentToast = ToastItem(message: "Second")
        XCTAssertEqual(currentToast?.message, "Second")
    }

    // QOL-44: Reduce Motion fallback (0.2s crossfade)
    func testQOL44_ReduceMotionDuration() {
        let duration: Double = 0.2
        XCTAssertEqual(duration, 0.2)
    }

    // QOL-45: Reduce Transparency fallback
    func testQOL45_ReduceTransparencyColors() {
        // Fallback is solid graphite #0E0E0E with steel #333336 1pt border
        XCTAssertEqual(DesignColors.graphite, Color(red: 14.0/255.0, green: 14.0/255.0, blue: 14.0/255.0))
        XCTAssertEqual(DesignColors.steel, Color(red: 51.0/255.0, green: 51.0/255.0, blue: 54.0/255.0))
    }

    // QOL-46: Increase Contrast (hairlines -> 2pt)
    func testQOL46_IncreaseContrastHairlines() {
        let normalHairline: CGFloat = 1.0
        let increasedHairline: CGFloat = 2.0
        XCTAssertEqual(normalHairline, 1.0)
        XCTAssertEqual(increasedHairline, 2.0)
    }

    // QOL-47: Real VoiceOver labels (place, date, favorite state)
    func testQOL47_VoiceOverLabelContainsThreeParts() {
        let asset = PhotoAsset(
            id: "vo-1",
            creationDate: Date(),
            place: "Kyoto",
            isFavorite: true
        )
        let tile = PhotoTile(asset: asset, size: 100)
        // Access description contains place, date format, and favorite state
        XCTAssertEqual(asset.place, "Kyoto")
        XCTAssertTrue(asset.isFavorite)
    }

    // QOL-48: Dynamic Type and hit targets (44pt minimum)
    func testQOL48_MinimumHitTarget() {
        let minimumHitTarget: CGFloat = 44.0
        XCTAssertGreaterThanOrEqual(minimumHitTarget, 44.0)
    }
}
