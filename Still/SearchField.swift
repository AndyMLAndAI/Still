import SwiftUI

public struct SearchField: View {
    @Binding public var text: String
    public var onCommit: () -> Void

    public init(text: Binding<String>, onCommit: @escaping () -> Void = {}) {
        self._text = text
        self.onCommit = onCommit
    }

    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignColors.ash)

            TextField("Search", text: $text)
                .font(DesignFonts.body())
                .foregroundColor(DesignColors.porcelain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit(onCommit)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(DesignColors.ash)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .modifier(LiquidGlassModifier(isCapsule: true))
    }
}
