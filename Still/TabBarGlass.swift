import SwiftUI

public struct TabBarGlass: View {
    @Binding public var selectedTab: TabItem
    public var onReselect: (TabItem) -> Void

    @State private var isSquishing: Bool = false

    public init(selectedTab: Binding<TabItem>, onReselect: @escaping (TabItem) -> Void = { _ in }) {
        self._selectedTab = selectedTab
        self.onReselect = onReselect
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases) { tab in
                let isSelected = selectedTab == tab
                Button {
                    if isSelected {
                        onReselect(tab)
                    } else {
                        triggerSquish()
                        withAnimation(DesignMotion.tabSlide) {
                            selectedTab = tab
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImageName)
                            .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        Text(tab.title)
                            .font(DesignFonts.tabLabel())
                    }
                    .foregroundColor(isSelected ? DesignColors.porcelain : DesignColors.ash)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 298, height: 64)
        .modifier(LiquidGlassModifier(isCapsule: true))
        .scaleEffect(x: isSquishing ? 1.16 : 1.0, y: isSquishing ? 0.88 : 1.0)
    }

    private func triggerSquish() {
        withAnimation(.easeOut(duration: 0.15)) {
            isSquishing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                self.isSquishing = false
            }
        }
    }
}
