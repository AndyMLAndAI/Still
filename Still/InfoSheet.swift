import SwiftUI

public struct InfoSheet: View {
    public let asset: PhotoAsset
    public var onClose: () -> Void

    @State private var locationRemoved: Bool = false

    public init(asset: PhotoAsset, onClose: @escaping () -> Void = {}) {
        self.asset = asset
        self.onClose = onClose
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: asset.creationDate)
    }

    private var formattedSize: String {
        let bytes = asset.fileSizeBytes
        let mb = Double(bytes) / (1024.0 * 1024.0)
        return String(format: "%.1f MB", mb)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with close
            HStack {
                Text("Information")
                    .font(DesignFonts.headline())
                    .foregroundColor(DesignColors.porcelain)

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(DesignColors.ash)
                }
                .buttonStyle(.plain)
            }

            Divider()
                .background(DesignColors.steel)

            // Date
            VStack(alignment: .leading, spacing: 4) {
                Text("Date")
                    .font(DesignFonts.caption())
                    .foregroundColor(DesignColors.ash)
                Text(formattedDate)
                    .font(DesignFonts.body())
                    .foregroundColor(DesignColors.porcelain)
            }

            // Place
            VStack(alignment: .leading, spacing: 4) {
                Text("Place")
                    .font(DesignFonts.caption())
                    .foregroundColor(DesignColors.ash)
                Text(locationRemoved ? "Location Removed" : asset.place)
                    .font(DesignFonts.body())
                    .foregroundColor(locationRemoved ? DesignColors.ash : DesignColors.porcelain)
            }

            // File Size
            VStack(alignment: .leading, spacing: 4) {
                Text("File Size")
                    .font(DesignFonts.caption())
                    .foregroundColor(DesignColors.ash)
                Text(formattedSize)
                    .font(DesignFonts.body())
                    .foregroundColor(DesignColors.porcelain)
            }

            // Remove Location Control (QOL-27)
            Button {
                locationRemoved.toggle()
            } label: {
                HStack {
                    Image(systemName: locationRemoved ? "location.slash.fill" : "location.slash")
                    Text(locationRemoved ? "Location Removed" : "Remove Location")
                }
                .font(DesignFonts.body())
                .foregroundColor(locationRemoved ? DesignColors.ash : DesignColors.appleBlue)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(24)
        .background(DesignColors.carbon)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(DesignColors.steel, lineWidth: 1)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 24)
    }
}
