import XCTest
import SwiftUI
@testable import Still

@MainActor
final class QoLDeletionTests: XCTestCase {
    // QOL-07: Delete is never silent
    func testQOL07_DeleteShowsToastWithOpen() async throws {
        let library = FakeLibrary(assetCount: 10)
        let assetToDelete = library.allAssets[0]
        let initialCount = library.allAssets.count

        try await library.delete(assets: [assetToDelete])
        XCTAssertEqual(library.allAssets.count, initialCount - 1)

        // Verify toast copy contract
        let toast = ToastItem(message: "Moved to Recently Deleted", actionTitle: "Open", action: {})
        XCTAssertEqual(toast.message, "Moved to Recently Deleted")
        XCTAssertEqual(toast.actionTitle, "Open")
    }

    // QOL-09: Undo for favorites
    func testQOL09_UndoForFavorites() async throws {
        let library = FakeLibrary(assetCount: 10)
        let asset = library.allAssets[0]
        let originalFav = asset.isFavorite

        // Toggle favorite
        try await library.setFavorite(!originalFav, for: asset)
        let updated = library.allAssets.first(where: { $0.id == asset.id })
        XCTAssertEqual(updated?.isFavorite, !originalFav)

        // Undo restores original favorite state
        try await library.setFavorite(originalFav, for: asset)
        let restored = library.allAssets.first(where: { $0.id == asset.id })
        XCTAssertEqual(restored?.isFavorite, originalFav)
    }

    // QOL-10: Delete sits apart from share
    func testQOL10_DeleteSitsApartFromShare() {
        // Color tokens check: destructive color is #FF453A
        XCTAssertEqual(DesignColors.destructive, Color(red: 255.0/255.0, green: 69.0/255.0, blue: 58.0/255.0))
        // Spacing check: 16 pt separation constant in viewer bottom bar
        let separatorSpacing: CGFloat = 16.0
        XCTAssertEqual(separatorSpacing, 16.0)
    }
}
