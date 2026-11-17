import Foundation

public enum TabItem: String, CaseIterable, Identifiable, Sendable {
    case library = "Library"
    case search = "Search"

    public var id: String { rawValue }

    public var title: String { rawValue }

    public var systemImageName: String {
        switch self {
        case .library:
            return "photo.on.rectangle"
        case .search:
            return "magnifyingglass"
        }
    }
}
