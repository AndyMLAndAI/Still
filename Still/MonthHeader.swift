import SwiftUI

public struct MonthHeader: View {
    public let group: MonthGroup
    public let isSelectionMode: Bool
    public let isAllSelected: Bool
    public var onToggleSelection: () -> Void

    public init(
        group: MonthGroup,
        isSelectionMode: Bool = false,
        isAllSelected: Bool = false,
        onToggleSelection: @escaping () -> Void = {}
    ) {
        self.group = group
        self.isSelectionMode = isSelectionMode
        self.isAllSelected = isAllSelected
        self.onToggleSelection = onToggleSelection
    }

    public var body: some View {
        HStack {
            Text(group.title)
                .font(DesignFonts.monthHeader())
                .foregroundColor(DesignColors.ash)

            Spacer()

            if isSelectionMode {
                Button(action: onToggleSelection) {
                    Text(isAllSelected ? "Deselect All" : "Select All")
                        .font(DesignFonts.monthHeader())
                        .foregroundColor(DesignColors.appleBlue)
                }
                .buttonStyle(.plain)
            } else {
                Text("\(group.assets.count)")
                    .font(DesignFonts.monthHeader())
                    .foregroundColor(DesignColors.ash.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(height: 38)
        .background(DesignColors.obsidian.opacity(0.92))
    }
}
