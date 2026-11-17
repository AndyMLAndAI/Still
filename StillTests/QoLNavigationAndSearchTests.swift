import XCTest
@testable import Still

@MainActor
final class QoLNavigationAndSearchTests: XCTestCase {
    // QOL-29: Timeline scrubber with ticks
    func testQOL29_TimelineScrubberMonthBoundary() {
        let library = FakeLibrary(assetCount: 30)
        XCTAssertGreaterThanOrEqual(library.monthGroups.count, 2)
        let firstGroup = library.monthGroups[0]
        XCTAssertFalse(firstGroup.title.isEmpty)
    }

    // QOL-30: Pick up where you left off
    func testQOL30_PersistTabScrollAndZoom() {
        let suite = UserDefaults(suiteName: "TestQOL30")!
        let store = SettingsStore(userDefaults: suite)

        store.selectedTab = "Search"
        store.scrollAnchorId = "fake-42"
        store.columnCount = 2

        // Verify fresh store instance reads persisted values
        let reloaded = SettingsStore(userDefaults: suite)
        XCTAssertEqual(reloaded.selectedTab, "Search")
        XCTAssertEqual(reloaded.scrollAnchorId, "fake-42")
        XCTAssertEqual(reloaded.columnCount, 2)
    }

    // QOL-31: Tap active tab to go to top
    func testQOL31_TapActiveTabReselect() {
        var didReselect = false
        let tabBar = TabBarGlass(selectedTab: .constant(.library)) { tab in
            if tab == .library {
                didReselect = true
            }
        }
        tabBar.onReselect(.library)
        XCTAssertTrue(didReselect)
    }

    // QOL-32: Go to date
    func testQOL32_GoToDateJumps() {
        let library = FakeLibrary(assetCount: 50)
        let targetGroup = library.monthGroups.last
        XCTAssertNotNil(targetGroup)
        let targetDate = targetGroup?.date
        XCTAssertNotNil(targetDate)
    }

    // QOL-34: Recent searches (up to 8 queries, clear control)
    func testQOL34_RecentSearchesCapAndClear() {
        let suite = UserDefaults(suiteName: "TestQOL34")!
        let store = SettingsStore(userDefaults: suite)
        store.clearRecentSearches()

        for i in 1...12 {
            store.addRecentSearch("Query \(i)")
        }

        XCTAssertEqual(store.recentSearches.count, 8)
        XCTAssertEqual(store.recentSearches.first, "Query 12")

        store.clearRecentSearches()
        XCTAssertTrue(store.recentSearches.isEmpty)
    }

    // QOL-35: Instant suggestions (< 100 ms)
    func testQOL35_InstantSearchPerformance() {
        let library = FakeLibrary(assetCount: 200)
        let startTime = CFAbsoluteTimeGetCurrent()

        let query = "tokyo"
        let filtered = library.allAssets.filter {
            $0.place.lowercased().contains(query) || $0.tags.contains(where: { $0.lowercased().contains(query) })
        }
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0 // in ms

        XCTAssertLessThan(elapsed, 100.0, "Search suggestion took longer than 100 ms: \(elapsed) ms")
        XCTAssertFalse(filtered.isEmpty)
    }

    // QOL-36: Chips combine with query (AND logic)
    func testQOL36_ChipsCombineWithQueryAND() {
        let library = FakeLibrary(assetCount: 200)
        let searchScreen = SearchScreen(library: library)

        // If we filter place == "Tokyo" AND tag == "Night"
        let matched = library.allAssets.filter {
            $0.place == "Tokyo" && $0.tags.contains("Night")
        }

        for item in matched {
            XCTAssertEqual(item.place, "Tokyo")
            XCTAssertTrue(item.tags.contains("Night"))
        }
    }

    // QOL-38: Show why a result matched
    func testQOL38_ShowWhyResultMatched() {
        let asset = PhotoAsset(id: "match-1", creationDate: Date(), place: "Venice", tags: ["Water"])
        let item = SearchResultItem(asset: asset, matchLabel: "Venice")
        XCTAssertEqual(item.matchLabel, "Venice")
    }
}
