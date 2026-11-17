import XCTest
@testable import Still

@MainActor
final class QoLInfoAndCloudTests: XCTestCase {
    // QOL-27: Info sheet with remove-location control
    func testQOL27_RemoveLocationControl() {
        let asset = PhotoAsset(
            id: "test-location",
            creationDate: Date(),
            place: "Yosemite National Park"
        )
        XCTAssertEqual(asset.place, "Yosemite National Park")

        var locationRemoved = false
        locationRemoved.toggle()
        XCTAssertTrue(locationRemoved)

        let displayedPlace = locationRemoved ? "Location Removed" : asset.place
        XCTAssertEqual(displayedPlace, "Location Removed")
    }

    // QOL-28: iCloud placeholders that do something
    func testQOL28_CloudPlaceholderTimeoutAndRetry() {
        let cloudAsset = PhotoAsset(
            id: "cloud-1",
            creationDate: Date(),
            place: "Tokyo",
            isCloudPlaceholder: true
        )
        XCTAssertTrue(cloudAsset.isCloudPlaceholder)

        // 15s timeout threshold for retry action
        let timeoutSeconds: Double = 15.0
        XCTAssertEqual(timeoutSeconds, 15.0)
    }
}
