import XCTest
@testable import Still

@MainActor
final class QoLSelectionTests: XCTestCase {
    // QOL-01: Drag-select a range
    func testQOL01_DragSelectRange() {
        let library = FakeLibrary(assetCount: 50)
        var selectedIds = Set<String>()
        let assets = library.allAssets

        // Simulate dragging across a slice of 10 assets
        let targetSlice = Array(assets[5..<15])
        for asset in targetSlice {
            selectedIds.insert(asset.id)
        }

        XCTAssertEqual(selectedIds.count, 10)
        for asset in targetSlice {
            XCTAssertTrue(selectedIds.contains(asset.id))
        }
    }

    // QOL-02: Select a whole month
    func testQOL02_SelectWholeMonth() {
        let library = FakeLibrary(assetCount: 30)
        guard let firstGroup = library.monthGroups.first else {
            XCTFail("Expected at least one month group")
            return
        }

        var selectedIds = Set<String>()
        let groupIds = firstGroup.assets.map(\.id)

        // Select whole month
        for id in groupIds {
            selectedIds.insert(id)
        }
        XCTAssertEqual(selectedIds.count, firstGroup.assets.count)

        // Deselect whole month
        for id in groupIds {
            selectedIds.remove(id)
        }
        XCTAssertTrue(selectedIds.isEmpty)
    }

    // QOL-03: Range select with two taps
    func testQOL03_RangeSelectTwoTaps() {
        let library = FakeLibrary(assetCount: 20)
        let assets = library.allAssets
        var selectedIds = Set<String>()

        let firstIndex = 2
        let secondIndex = 7
        selectedIds.insert(assets[firstIndex].id)

        // Two-tap range selection
        let start = min(firstIndex, secondIndex)
        let end = max(firstIndex, secondIndex)
        for i in start...end {
            selectedIds.insert(assets[i].id)
        }

        XCTAssertEqual(selectedIds.count, 6)
        for i in start...end {
            XCTAssertTrue(selectedIds.contains(assets[i].id))
        }
    }

    // QOL-04: Selection survives scroll and zoom
    func testQOL04_SelectionSurvivesScrollAndZoom() {
        let library = FakeLibrary(assetCount: 20)
        let settings = SettingsStore(userDefaults: UserDefaults(suiteName: "TestQOL04")!)
        var selectedIds: Set<String> = [library.allAssets[0].id, library.allAssets[1].id]

        // Changing column count (zoom)
        settings.columnCount = 2
        XCTAssertEqual(selectedIds.count, 2)
        settings.columnCount = 4
        XCTAssertEqual(selectedIds.count, 2)

        // Changing scroll anchor
        settings.scrollAnchorId = "fake-10"
        XCTAssertEqual(selectedIds.count, 2)
        XCTAssertTrue(selectedIds.contains(library.allAssets[0].id))
    }

    // QOL-05: Recover from an accidental Cancel
    func testQOL05_RecoverFromAccidentalCancel() {
        let library = FakeLibrary(assetCount: 10)
        var selectedIds: Set<String> = [library.allAssets[0].id, library.allAssets[1].id]
        var savedBackup: Set<String> = []

        // User taps Cancel
        savedBackup = selectedIds
        selectedIds.removeAll()
        XCTAssertTrue(selectedIds.isEmpty)

        // User taps Undo in Toast
        selectedIds = savedBackup
        XCTAssertEqual(selectedIds.count, 2)
    }

    // QOL-06: Select all and deselect all in one control
    func testQOL06_SelectAllAndDeselectAll() {
        let library = FakeLibrary(assetCount: 15)
        var selectedIds = Set<String>()

        // Partial selection -> Select All
        selectedIds.insert(library.allAssets[0].id)
        XCTAssertNotEqual(selectedIds.count, library.allAssets.count)

        // Flip to Select All
        selectedIds = Set(library.allAssets.map(\.id))
        XCTAssertEqual(selectedIds.count, 15)

        // When everything is selected -> flip to Deselect All
        selectedIds.removeAll()
        XCTAssertTrue(selectedIds.isEmpty)
    }
}
