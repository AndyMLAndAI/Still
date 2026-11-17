import SwiftUI

public enum DesignFonts {
    public static func largeTitle() -> Font {
        .system(size: 34, weight: .bold, design: .default)
    }

    public static func monthHeader() -> Font {
        .system(size: 13, weight: .semibold, design: .default)
    }

    public static func tabLabel() -> Font {
        .system(size: 10, weight: .semibold, design: .default)
    }

    public static func toastText() -> Font {
        .system(size: 15, weight: .regular, design: .default)
    }

    public static func toastAction() -> Font {
        .system(size: 15, weight: .semibold, design: .default)
    }

    public static func viewerCounter() -> Font {
        .system(size: 15, weight: .semibold, design: .default).monospacedDigit()
    }

    public static func body() -> Font {
        .system(size: 17, weight: .regular, design: .default)
    }

    public static func headline() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    public static func caption() -> Font {
        .system(size: 12, weight: .medium, design: .default)
    }

    public static func searchChip() -> Font {
        .system(size: 13, weight: .medium, design: .default)
    }
}
