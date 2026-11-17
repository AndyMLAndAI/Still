import SwiftUI

public struct SelectionBar: View {
    public let selectedCount: Int
    public let totalCount: Int
    public var onShare: () -> Void
    public var onFavorite: () -> Void
    public var onDelete: () -> Void
    public var onToggleSelectAll: () -> Void

    public init(
        selectedCount: Int,
        totalCount: Int,
        onShare: @escaping () -> Void = {},
        onFavorite: @escaping () -> Void = {},
        onDelete: @escaping () -> Void = {},
        onToggleSelectAll: @escaping () -> Void = {}
    ) {
        self.selectedCount = selectedCount
        self.totalCount = totalCount
        self.onShare = onShare
        self.onFavorite = onFavorite
        self.onDelete = onDelete
        self.onToggleSelectAll = onToggleSelectAll
    }

    private var hasSelection: Bool {
        selectedCount > 0
    }

    private var isAllSelected: Bool {
        totalCount > 0 && selectedCount == totalCount
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Share Action
            Button(action: onShare) {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                    Text("Share")
                        .font(DesignFonts.tabLabel())
                }
                .foregroundColor(hasSelection ? DesignColors.porcelain : DesignColors.slate)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .disabled(!hasSelection)

            // Select All / Deselect All + Count
            Button(action: onToggleSelectAll) {
                VStack(spacing: 2) {
                    Text("\(selectedCount) Selected")
                        .font(DesignFonts.headline())
                        .foregroundColor(DesignColors.porcelain)
                    Text(isAllSelected ? "Deselect All" : "Select All")
                        .font(DesignFonts.caption())
                        .foregroundColor(DesignColors.appleBlue)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            // Favorite Action
            Button(action: onFavorite) {
                VStack(spacing: 4) {
                    Image(systemName: "heart")
                        .font(.system(size: 20))
                    Text("Favorite")
                        .font(DesignFonts.tabLabel())
                }
                .foregroundColor(hasSelection ? DesignColors.porcelain : DesignColors.slate)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .disabled(!hasSelection)

            // Delete Action (Destructive #FF453A)
            Button(action: onDelete) {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                    Text("Delete")
                        .font(DesignFonts.tabLabel())
                }
                .foregroundColor(hasSelection ? DesignColors.destructive : DesignColors.slate)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .disabled(!hasSelection)
        }
        .padding(.horizontal, 8)
        .frame(height: 70)
        .modifier(LiquidGlassModifier(isCapsule: true))
        .padding(.horizontal, 12)
    }
}
