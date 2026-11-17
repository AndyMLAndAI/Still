import SwiftUI

@MainActor
public final class SettingsStore: ObservableObject {
    public static let shared = SettingsStore()

    private enum Keys {
        static let selectedTab = "still.selectedTab"
        static let scrollAnchorId = "still.scrollAnchorId"
        static let columnCount = "still.columnCount"
        static let hapticsEnabled = "still.hapticsEnabled"
        static let recentSearches = "still.recentSearches"
    }

    private let userDefaults: UserDefaults

    @Published public var selectedTab: String {
        didSet { userDefaults.set(selectedTab, forKey: Keys.selectedTab) }
    }

    @Published public var scrollAnchorId: String? {
        didSet { userDefaults.set(scrollAnchorId, forKey: Keys.scrollAnchorId) }
    }

    @Published public var columnCount: Int {
        didSet {
            let clamped = max(2, min(4, columnCount))
            userDefaults.set(clamped, forKey: Keys.columnCount)
        }
    }

    @Published public var hapticsEnabled: Bool {
        didSet { userDefaults.set(hapticsEnabled, forKey: Keys.hapticsEnabled) }
    }

    @Published public var recentSearches: [String] {
        didSet {
            let trimmed = Array(recentSearches.prefix(8))
            userDefaults.set(trimmed, forKey: Keys.recentSearches)
        }
    }

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.selectedTab = userDefaults.string(forKey: Keys.selectedTab) ?? "Library"
        self.scrollAnchorId = userDefaults.string(forKey: Keys.scrollAnchorId)
        let storedColumns = userDefaults.integer(forKey: Keys.columnCount)
        self.columnCount = storedColumns >= 2 && storedColumns <= 4 ? storedColumns : 3
        self.hapticsEnabled = userDefaults.object(forKey: Keys.hapticsEnabled) == nil ? true : userDefaults.bool(forKey: Keys.hapticsEnabled)
        self.recentSearches = userDefaults.stringArray(forKey: Keys.recentSearches) ?? []
    }

    public func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var list = recentSearches.filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        list.insert(trimmed, at: 0)
        recentSearches = Array(list.prefix(8))
    }

    public func clearRecentSearches() {
        recentSearches = []
    }
}
