# Still

Still is a hyperminimal, two-tab photo library app for iOS, designed with native SwiftUI and Liquid Glass floating chrome.

- **App Name**: Still
- **Bundle ID**: `com.andymlandai.still`
- **Target**: iOS 27.0, iPhone only
- **Canvas**: Pure black `#000000` canvas, `#0E0E0E` chrome, 0 pt photo tile corner radius, Dynamic Type throughout.

## Design Philosophy

- **Minimalist Restraint**: Pure monochrome chrome (Obsidian, Graphite, Carbon, Steel, Slate, Ash, Porcelain). Color exists only in the photos themselves, except for Apple Blue (`#0071E3`) on the selection checkmark and Destructive Red (`#FF453A`) on Delete and the filled favorite heart.
- **Floating Liquid Glass**: Clear material with white specular rim highlights on floating chrome only (Tab bar, Selection bar, Viewer chrome, Toast, Info sheet). Never on photos or body text.
- **Zero Photo Corner Radius**: Sharp, edge-to-edge square photo tiles with 2 pt gutters.
- **No Third-Party Dependencies**: Pure SwiftUI and native system frameworks.

## Architecture

- `AppShell`: Root container with two tabs (`Library`, `Search`), floating `TabBarGlass`, `SelectionBar`, and `ToastGlass`.
- `MediaLibrary`: Protocol defining photo operations (`assets()`, `thumbnail(for:size:)`, `fullImage(for:)`, `setFavorite(_:for:)`, `delete(_:)`, `changes`).
- `FakeLibrary`: In-memory implementation powering previews and unit tests across multiple months.
- `PhotoKitLibrary`: Native PhotoKit adapter for real on-device photo library access.
- `ThumbnailCache`: Capped at 60 MB with LRU eviction and memory pressure eviction.
- `HapticsService`: Haptic feedback engine respecting system settings.
- `SettingsStore`: Persistent user settings (last tab, scroll anchor, grid zoom level).

## Build & Run

### Prerequisites
- macOS with Xcode (or GitHub Actions on `macos-latest`)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Generate Xcode Project
```bash
xcodegen generate
```

### Run Tests
```bash
xcodebuild test \
  -scheme Still \
  -destination "platform=iOS Simulator,name=iPhone 17" \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

### Build Unsigned .ipa
```bash
xcodebuild \
  -scheme Still \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath build/Still.xcarchive \
  archive \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

mkdir -p build/Payload
cp -R build/Still.xcarchive/Products/Applications/*.app build/Payload/
cd build && zip -r Still.ipa Payload
```

## App Icon & Assets

- Master 1024x1024 px Liquid Glass icon generated in `Still/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`.
- Individual background and glass lens foreground layers are saved in `icon-layers/`.
- TODO: Open the layers in Icon Composer on a Mac to produce a layered `.icon` bundle when Mac hardware is available.

## License

TODO: Choose an open source license (do not pick one yet).
