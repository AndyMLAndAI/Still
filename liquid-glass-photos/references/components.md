# Components

Each component is one Swift type in its own file. Name files after the type. Each has a SwiftUI preview that uses `FakeLibrary`.

## Contents
- App shell and navigation
- Library
- Viewer
- Selection
- For You
- Albums
- Search
- Feedback
- Data and services

## App shell and navigation

**AppShell**
Owns the four tabs and the active screen. Holds `AppState`. Places `TabBarGlass` and `SelectionBar` on top of the content.

**TabBarGlass**
Four tabs: Library, For You, Albums, Search. A single glass lens slides behind the selected tab and squishes as it moves. Hidden while selection mode or the viewer is active.
- States: idle, moving, hidden.
- Interaction: tap a tab to switch. Tap the active tab to scroll that screen to the top.

**ZoomSegmented**
Segmented control for Years, Months, Days, All. Sits under the Library title.
- Interaction: tap a segment, or pinch in the grid (QOL-17).

## Library

**LibraryScreen**
Title, `ZoomSegmented`, the month-grouped grid, and the `TimelineScrubber`.

**PhotoGrid**
Lazy grid. Column count comes from zoom level: Years 6, Months 4, Days 3, All 2. Holds scroll position across zoom changes by anchoring on the visible month.

**MonthHeader**
Sticky section header with the month name and item count. Tapping it selects or deselects the whole section (QOL-02).

**PhotoTile**
A square thumbnail with state overlays: favorite heart (bottom-left), burst count (top-left), iCloud placeholder (top-right), and selection check (top-right).
- States: idle, pressed, selected, placeholder, loading (blur-up thumbnail).
- Interactions: tap to open, long-press to enter selection, drag to select a range, swipe leading to favorite (QOL-11).

**PhotoStackTile**
A burst or duplicate group shown as one tile with a count. Tap to fan out (QOL-16).

**TimelineScrubber**
Vertical track on the right edge. Dragging it jumps the grid. Shows a floating month label while dragging. Haptic tick at each month boundary (QOL-29).

**GoToDateSheet**
Calendar picker in a `carbon` sheet. Jumps to the chosen date.

## Viewer

**PhotoViewer**
Full-screen photo. Opens with a shared-element zoom from the tile. Handles swipe between photos, drag-down to dismiss, and pinch and double-tap zoom.
- States: idle, zoomed, dragging, dismissing, loading.

**ViewerTopBar**
Glass pill with a close control, counter (`3 of 42`), and an info toggle. Hides when the chrome is toggled off (QOL-19).

**ViewerBottomBar**
Glass capsule with favorite, share, info, and delete. Delete sits apart from the others (QOL-10).

**InfoSheet**
`carbon` sheet with date, place, camera details, file size, and map. Includes a "Remove location" control for sharing (QOL-27).

**HeartBurst**
Large heart that scales in and fades out over 0.85s, played on double-tap. Does not replay if the photo is already a favorite.

**EditCompareView**
Press and hold to show the original while an edit is applied (QOL-22).

**FilmstripScrubber**
Optional thumbnail strip at the bottom of the viewer for jumping. Toggle in settings (QOL-26).

## Selection

**SelectionBar**
Glass capsule shown in selection mode. Share, selected count, favorite, delete. Delete is red. Actions are disabled when nothing is selected.

**SelectionOverlay**
Applies the selection check and the tile shrink to selected tiles. Draws the drag-select region.

## For You

**MemoryScreen**
Hero stage with the story progress bars, a memory collage, and the title and subtitle.

**MemoryStage**
The 28pt-radius hero. Holds the iridescent backdrop when that memory uses it. Auto-advances every 5s. Pauses while held. Tap the left half to go back and the right half to go forward.

**StoryProgressBars**
One bar per memory. Completed bars fill, the active bar animates, later bars stay empty.

**MemoryCollage**
Three floating photo cards that drift slowly, each 150x190 with 18pt radius. Motion is disabled under Reduce Motion.

**MemoryActions**
Play and Keep pills. Keep saves the memory to Favorites and shows a toast.

## Albums

**AlbumsScreen**
Two-column grid of `AlbumCard`.

**AlbumCard**
Three stacked layers of photos, rotated and offset, plus name and count. Tap opens the album in the Library with a back control.

**AlbumDropTarget**
Drop zone on each card. Dragging a photo onto a card adds it to that album (QOL-12).

## Search

**SearchScreen**
Title, `SearchField`, `SearchChips`, and results.

**SearchField**
Pill-shaped field. Keeps the last query. Shows recent searches when empty (QOL-34).

**SearchChips**
Horizontal row of places, subjects, and months. Chips combine with the query (QOL-36).

**SearchResults**
Grid of results, with an empty state that says what to try.

## Feedback

**ToastGlass**
Glass capsule near the bottom. Text plus an optional action (Undo or Open). Auto-dismisses after 4s and stays longer while the user is touching it. Only one toast at a time; a new one replaces the old.

**EmptyState**
Title, one line of guidance, and an action when there is one. Every empty screen uses it (QOL-42).

**PermissionState**
Shown when library access is denied or limited. Offers Select More Photos or Open Settings (QOL-49, QOL-50).

**DownloadPlaceholder**
Shown for iCloud items that are not on the device. Has a download control and a timeout with retry (QOL-28).

## Data and services

**MediaLibrary** (protocol)
`assets()`, `albums()`, `thumbnail(for:size:)`, `fullImage(for:)`, `setFavorite(_:for:)`, `delete(_:)`, `addToAlbum(_:album:)`, `changes`.

**FakeLibrary**
Generated assets with dates, places, tags, and bursts. Used by previews, tests, and development.

**PhotoKitLibrary**
Implements `MediaLibrary` on PhotoKit. Handles limited access and iCloud placeholders.

**ThumbnailCache**
Memory cache capped at 80MB with eviction (QOL-52).

**HapticsService**
Wraps system haptics. Respects the system haptic setting (QOL-40).

**SearchIndex**
Local, in-memory index of tags, places, and months. Built in the background. Adds OCR text from screenshots when available (QOL-37).

**SettingsStore**
Persists the last tab, scroll anchor, zoom level, and toggles across launches (QOL-30).
