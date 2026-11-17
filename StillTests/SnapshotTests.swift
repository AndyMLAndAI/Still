import XCTest
import SwiftUI
import CoreGraphics
import UIKit
@testable import Still

@MainActor
final class SnapshotTests: XCTestCase {
    private let targetSize = CGSize(width: 393, height: 852) // iPhone 17 reference canvas

    private func screenshotsDirectory() -> URL {
        let fileManager = FileManager.default
        let tempDir = URL(fileURLWithPath: "/tmp/screenshots", isDirectory: true)
        try? fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }

    private func saveImage(_ image: UIImage, name: String) {
        let dir = screenshotsDirectory()
        let fileURL = dir.appendingPathComponent("\(name).png")
        if let data = image.pngData() {
            try? data.write(to: fileURL)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // Snapshot test: Library screen at 393 x 852
    func testSnapshot_Library() {
        let library = FakeLibrary(assetCount: 30)
        let view = LibraryScreen(
            library: library,
            isSelectionMode: .constant(false),
            selectedAssetIds: .constant([]),
            onOpenViewer: { _ in },
            onShowToast: { _ in }
        )
        .frame(width: targetSize.width, height: targetSize.height)
        .background(DesignColors.obsidian)
        .preferredColorScheme(.dark)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        renderer.proposedSize = ProposedViewSize(targetSize)

        guard let uiImage = renderer.uiImage else {
            XCTFail("Failed to render Library screen snapshot")
            return
        }

        XCTAssertEqual(uiImage.size.width, targetSize.width)
        XCTAssertEqual(uiImage.size.height, targetSize.height)
        saveImage(uiImage, name: "Library-393x852")
    }

    // Snapshot test: PhotoViewer screen at 393 x 852
    func testSnapshot_Viewer() {
        let library = FakeLibrary(assetCount: 10)
        let view = PhotoViewer(
            assets: library.allAssets,
            currentIndex: .constant(0),
            library: library
        )
        .frame(width: targetSize.width, height: targetSize.height)
        .background(DesignColors.obsidian)
        .preferredColorScheme(.dark)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        renderer.proposedSize = ProposedViewSize(targetSize)

        guard let uiImage = renderer.uiImage else {
            XCTFail("Failed to render PhotoViewer snapshot")
            return
        }

        XCTAssertEqual(uiImage.size.width, targetSize.width)
        XCTAssertEqual(uiImage.size.height, targetSize.height)
        saveImage(uiImage, name: "Viewer-393x852")
    }

    // Snapshot test: Selection mode screen at 393 x 852
    func testSnapshot_Selection() {
        let library = FakeLibrary(assetCount: 30)
        let selectedIds: Set<String> = [library.allAssets[0].id, library.allAssets[1].id, library.allAssets[2].id]

        let view = ZStack(alignment: .bottom) {
            LibraryScreen(
                library: library,
                isSelectionMode: .constant(true),
                selectedAssetIds: .constant(selectedIds),
                onOpenViewer: { _ in },
                onShowToast: { _ in }
            )

            SelectionBar(
                selectedCount: selectedIds.count,
                totalCount: library.allAssets.count
            )
            .padding(.bottom, 26)
        }
        .frame(width: targetSize.width, height: targetSize.height)
        .background(DesignColors.obsidian)
        .preferredColorScheme(.dark)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        renderer.proposedSize = ProposedViewSize(targetSize)

        guard let uiImage = renderer.uiImage else {
            XCTFail("Failed to render Selection snapshot")
            return
        }

        XCTAssertEqual(uiImage.size.width, targetSize.width)
        XCTAssertEqual(uiImage.size.height, targetSize.height)
        saveImage(uiImage, name: "Selection-393x852")
    }

    // Snapshot test: Search screen at 393 x 852
    func testSnapshot_Search() {
        let library = FakeLibrary(assetCount: 30)
        let view = SearchScreen(library: library)
            .frame(width: targetSize.width, height: targetSize.height)
            .background(DesignColors.obsidian)
            .preferredColorScheme(.dark)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        renderer.proposedSize = ProposedViewSize(targetSize)

        guard let uiImage = renderer.uiImage else {
            XCTFail("Failed to render Search snapshot")
            return
        }

        XCTAssertEqual(uiImage.size.width, targetSize.width)
        XCTAssertEqual(uiImage.size.height, targetSize.height)
        saveImage(uiImage, name: "Search-393x852")
    }

    // Snapshot check: Tile corners are radius 0 at the pixel level
    func testSnapshot_TileCornersRadiusZeroAtPixelLevel() {
        let asset = PhotoAsset(id: "corner-test", creationDate: Date(), place: "Tokyo")
        let tileSize: CGFloat = 120.0

        // Create a solid test tile
        let tileView = PhotoTile(
            asset: asset,
            size: tileSize
        )
        .frame(width: tileSize, height: tileSize)

        let renderer = ImageRenderer(content: tileView)
        renderer.scale = 1.0
        renderer.proposedSize = ProposedViewSize(width: tileSize, height: tileSize)

        guard let uiImage = renderer.uiImage, let cgImage = uiImage.cgImage else {
            XCTFail("Failed to render PhotoTile for corner test")
            return
        }

        let width = cgImage.width
        let height = cgImage.height
        XCTAssertEqual(width, Int(tileSize))
        XCTAssertEqual(height, Int(tileSize))

        // Read pixels
        guard let pixelData = cgImage.dataProvider?.data,
              let ptr = CFDataGetBytePtr(pixelData) else {
            XCTFail("Failed to read pixel data from CGImage")
            return
        }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow

        // Check the four corners: (0, 0), (width-1, 0), (0, height-1), (width-1, height-1)
        let cornerCoords: [(x: Int, y: Int)] = [
            (0, 0),
            (width - 1, 0),
            (0, height - 1),
            (width - 1, height - 1)
        ]

        for coord in cornerCoords {
            let offset = coord.y * bytesPerRow + coord.x * bytesPerPixel
            let alpha = ptr[offset + 3]
            // If corner radius was rounded, corner pixels would be transparent (alpha == 0)
            // With corner radius 0, corner pixel must be fully opaque (alpha == 255)
            XCTAssertEqual(alpha, 255, "Corner at (\(coord.x), \(coord.y)) must have alpha 255 (radius 0), but found \(alpha)")
        }
    }
}
