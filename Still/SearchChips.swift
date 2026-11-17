import SwiftUI

public struct SearchChips: View {
    public let chips: [SearchChip]
    @Binding public var selectedChipIds: Set<String>
    public var onToggleChip: (SearchChip) -> Void

    public init(
        chips: [SearchChip],
        selectedChipIds: Binding<Set<String>>,
        onToggleChip: @escaping (SearchChip) -> Void = { _ in }
    ) {
        self.chips = chips
        self._selectedChipIds = selectedChipIds
        self.onToggleChip = onToggleChip
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips) { chip in
                    let isSelected = selectedChipIds.contains(chip.id)
                    Button {
                        if isSelected {
                            selectedChipIds.remove(chip.id)
                        } else {
                            selectedChipIds.insert(chip.id)
                        }
                        onToggleChip(chip)
                        HapticsService.shared.tick()
                    } label: {
                        Text(chip.title)
                            .font(DesignFonts.searchChip())
                            .foregroundColor(isSelected ? DesignColors.porcelain : DesignColors.ash)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected ? DesignColors.carbon : DesignColors.graphite)
                                    .overlay(
                                        Capsule()
                                            .stroke(isSelected ? DesignColors.porcelain : DesignColors.steel, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
