# Quality-of-life list

Each item names a real annoyance, the fix, and a check for done. Numbers are stable: components and other docs refer to them, so do not renumber. New items go at the end of their section, or at the end of the file with the next free number.

Build these in phase 8 of `SKILL.md`, one at a time, each with a test on `FakeLibrary`. Items that depend on PhotoKit are marked **[PhotoKit]**. Test those on the adapter, not the fake.

## Contents
- Selection (01 to 06)
- Deleting and recovery (07 to 10)
- Organizing (11 to 18)
- Viewing (19 to 28)
- Navigation and state (29 to 34)
- Search (35 to 38)
- Sharing (39)
- Feedback and feel (40 to 46)
- Accessibility (47 to 48)
- Resilience (49 to 55)
- Development workflow (56 to 57)

## Selection

**QOL-01 Drag-select a range.** Annoyance: selecting 100 photos means 100 taps. Fix: press and drag across tiles to select everything crossed. Edges autoscroll, with a light haptic each time a new row enters. Done when dragging across 200 tiles selects every tile crossed and nothing else.

**QOL-02 Select a whole month.** Annoyance: no way to grab a month at once. Fix: tapping a `MonthHeader` selects every item in that section. Tapping again clears them. The label reads "Select all" or "Deselect all". Done when the header toggles its section and the count matches.

**QOL-03 Range select with two taps.** Annoyance: selecting a block means dragging through it. Fix: after one photo is selected, long-pressing a second selects everything between them in grid order. Done when the range covers both ends and the rows between.

**QOL-04 Selection survives scroll and zoom.** Annoyance: changing zoom or scrolling loses the selection. Fix: selection is keyed by asset ID and persists until the user leaves selection mode or acts. Done when zoom and scroll leave the count unchanged.

**QOL-05 Recover from an accidental Cancel.** Annoyance: one wrong tap on Cancel throws away a long selection. Fix: Cancel shows a 5s toast with Undo that restores the selection. Done when Undo restores the exact set.

**QOL-06 Select all and deselect all in one control.** Annoyance: clearing a big selection takes forever. Fix: the selection bar shows "Select All" when partial and "Deselect All" when everything is selected. Done when the label flips on the last change.

## Deleting and recovery

**QOL-07 [PhotoKit] Delete is never silent.** Annoyance: deleting feels random, and it is unclear where the photos went. Fix: the system confirmation dialog is the one confirmation. After it succeeds, the toast reads "Moved to Recently Deleted" with an Open action that takes the user to that album. Done when a successful delete always shows the toast and the Open action reaches Recently Deleted.

**QOL-08 Undo for in-app-only actions.** Annoyance: removing a photo from a custom album or hiding it is permanent in the user's head. Fix: removing from an album, hiding, and Keep on a memory each show a 5s Undo toast. Done when each undo restores the prior state exactly.

**QOL-09 Undo for favorites.** Annoyance: an accidental double tap or swipe favorites something with no way back. Fix: a favorite change shows a 3s toast with Undo. Done when Undo returns the previous favorite state.

**QOL-10 Delete sits apart from share.** Annoyance: the trash icon is next to share, and a sloppy tap sends or deletes. Fix: in the viewer, delete sits at the far end of the bottom bar, 16pt away from the other controls, in `destructive` color. Done when the spacing and color are checked in a test or screenshot.

## Organizing

**QOL-11 Favorite by swiping.** Annoyance: favoriting needs a full-screen trip. Fix: swipe a tile right to favorite and left to add to an album. Done when both swipes work and each shows its result toast.

**QOL-12 Drag a photo onto an album.** Annoyance: adding to an album takes three menus. Fix: drag a tile onto an `AlbumCard` in Albums, or onto the album name in the Library. The card highlights while a photo is over it. Done when a drop adds the asset and shows a toast.

**QOL-13 Pin and reorder albums.** Annoyance: albums are in a fixed order and the ones you use are buried. Fix: long-press to pin, and drag to reorder pinned albums. Done when order persists across launches.

**QOL-14 Hide without a lock screen.** Annoyance: hiding a photo puts it somewhere hard to find. Fix: hide removes it from the Library, Memories, and Search, and places it in a Hidden album. Hidden stays behind a single Show Hidden toggle in Settings, which is off by default and needs no lock. Done when hidden photos never appear in the main screens.

**QOL-15 Surface duplicates, never delete them.** Annoyance: duplicates clutter the library and cleanup tools feel risky. Fix: a duplicate group shows a badge with a count. "Review" opens a side-by-side view with "Keep best" as the default action. Nothing is deleted without selection and confirmation. Done when the review flow never deletes on its own.

**QOL-16 Bursts stack and fan out.** Annoyance: a burst of 40 near-identical shots fills the grid. Fix: a burst shows one `PhotoStackTile` with a count. Tapping fans it out inline. Done when the stack collapses and expands without losing selection.

**QOL-17 Pinch the grid to change density.** Annoyance: changing layout means tapping a segmented control. Fix: pinching the grid moves one zoom level per gesture, with a haptic at each level. Done when pinch in and out cycle all four levels.

**QOL-18 Sort by captured or added date.** Annoyance: imports from a computer show up at the wrong place in the timeline. Fix: a sort control in the Library menu switches between captured and added date. Done when the choice persists and the grid regroups.

## Viewing

**QOL-19 Hide the chrome with one tap.** Annoyance: the controls cover the photo. Fix: tapping the photo toggles the top and bottom bars with a 0.3s fade. Done when a second tap restores them.

**QOL-20 Zoom in the viewer.** Annoyance: zooming in the stock viewer is fiddly. Fix: pinch to zoom, double tap to zoom to the tap point, and pan with momentum. Swiping only changes photos when the image is at fit scale. Done when zoomed panning never flips to the next photo.

**QOL-21 No blank frames while swiping.** Annoyance: swiping to the next photo sometimes shows a grey flash. Fix: the viewer prefetches the previous and next full images, and shows the thumbnail while the full image loads. Done when swiping through 20 photos shows no empty frame.

**QOL-22 Hold to see the original.** Annoyance: after editing, there is no quick way to compare. Fix: pressing and holding the photo shows the original until release. Done when the edited and original images swap on press and release.

**QOL-23 Edits are reversible.** Annoyance: it is unclear whether an edit can be undone. Fix: every edit is stored separately, and "Revert to original" is always in the edit menu. Done when revert restores the original pixels.

**QOL-24 Copy and paste edits.** Annoyance: applying the same adjustments to 30 photos takes 30 sessions. Fix: "Copy Edits" in the viewer menu and "Paste Edits" in the selection menu. Done when pasted edits match the source.

**QOL-25 [PhotoKit] Live Photos play on press.** Annoyance: Live Photos look like stills until you find the hidden motion. Fix: pressing and holding a Live Photo plays it, and the still shows instantly. Done when press plays and release returns to the still.

**QOL-26 Filmstrip for fast jumps.** Annoyance: moving 30 photos forward means 30 swipes. Fix: an optional thumbnail strip at the bottom of the viewer. Dragging it jumps. The toggle is in Settings. Done when a drag on the strip lands on the chosen photo.

**QOL-27 Info sheet with a remove-location control.** Annoyance: sharing sends the location without warning. Fix: the info sheet shows date, place, camera, file size, and a map. "Remove Location" is one tap and applies to shares from the session. Done when a shared image has no GPS data when that option is on.

**QOL-28 [PhotoKit] iCloud placeholders that do something.** Annoyance: an item that is not on the device shows a spinner forever. Fix: the tile shows a cloud icon. Opening it shows a download control. A download that takes more than 15s shows a Retry action. Done when the spinner never runs past 15s without an action.

## Navigation and state

**QOL-29 Timeline scrubber with ticks.** Annoyance: finding a year means flicking for minutes. Fix: `TimelineScrubber` on the right edge. It shows the month while dragging, and a haptic tick plays at each month boundary. Done when the scrubber lands on the correct month for the 42-item fixture.

**QOL-30 Pick up where you left off.** Annoyance: relaunching resets the tab, scroll position, and zoom. Fix: `SettingsStore` restores last tab, scroll anchor, and zoom level on launch. Done when relaunch lands on the same screen and month.

**QOL-31 Tap the active tab to go to the top.** Annoyance: the top of a long list is hard to reach. Fix: tapping the active tab scrolls to the top. A second tap on a scrolled-to-top screen returns to the root. Done when both taps behave as described.

**QOL-32 Go to date.** Annoyance: jumping to a day from last year means scrolling. Fix: "Go to Date" in the Library menu opens `GoToDateSheet`, and the grid jumps to that day. Done when the chosen day is visible after the jump.

**QOL-33 No trapped back gestures.** Annoyance: some stock screens need a precise tap on a small back button. Fix: every pushed screen, sheet, and the viewer dismisses with the edge swipe or the system back gesture. Done when each screen exits by edge swipe.

**QOL-34 Recent searches.** Annoyance: retyping the same search. Fix: the search field shows the last 8 queries when empty, with a control to clear them. Done when a query appears in recents after running and clearing removes it.

## Search

**QOL-35 Instant suggestions.** Annoyance: search lags as you type. Fix: suggestions come from `SearchIndex` in under 100ms. Results update as the query changes, with no submit step. Done when a suggestion appears within 100ms on the fixture.

**QOL-36 Chips combine with the query.** Annoyance: narrowing a search needs a new query. Fix: tapping a chip adds it as a filter alongside the text. Done when two chips and text intersect correctly.

**QOL-37 [PhotoKit] Search screenshots by their text.** Annoyance: a receipt or a sign from a screenshot is not findable. Fix: `SearchIndex` runs on-device OCR over screenshots in the background and indexes the text. Done when a word printed in a fixture screenshot returns that screenshot.

**QOL-38 Show why a result matched.** Annoyance: results look random. Fix: each result shows a small label, such as "Coast" or "Text: receipt". Done when every result carries a label.

## Sharing

**QOL-39 Remember share choices.** Annoyance: the quality and location choices reset every time. Fix: the last choices for full quality and location removal are remembered for the session, and shown in the share sheet. Done when a second share uses the remembered choices.

## Feedback and feel

**QOL-40 Haptics that mean something.** Annoyance: taps feel the same whether they matter or not. Fix: light on selection, medium on delete, a tick on each zoom level and each month boundary, and a success on favorite. `HapticsService` respects the system haptic setting. Done when each event maps to one haptic and the setting turns them off.

**QOL-41 Thumbnails appear instantly.** Annoyance: grids show blank squares while loading. Fix: a blurred low-resolution version shows within 100ms, then sharpens. Done when no tile is blank for more than 100ms on the fixture.

**QOL-42 Empty states that teach.** Annoyance: an empty Favorites screen says nothing useful. Fix: `EmptyState` names the next step. Example: "Nothing in Favorites yet. Double-tap a photo to favorite it." Done when every empty screen has a line of guidance and an action where one exists.

**QOL-43 Toasts never cover what matters.** Annoyance: a toast sits on top of the control you need. Fix: one toast at a time, above the tab bar, and it moves up when the keyboard or a sheet is open. Done when a second toast replaces the first and nothing is covered.

**QOL-44 Reduce Motion fallback.** Annoyance: zooms and springs make some people sick. Fix: with Reduce Motion on, transitions become 0.2s crossfades and the memory collage stops drifting. Done when the setting removes all zoom and drift.

**QOL-45 Reduce Transparency fallback.** Annoyance: glass is hard to read on busy photos. Fix: with Reduce Transparency on, glass becomes solid `graphite` with a 1pt `steel` border. Done when no glass renders with the setting on.

**QOL-46 Increase Contrast.** Annoyance: secondary text is too faint. Fix: `ash` text becomes `porcelain` and hairlines become 2pt. Done when the contrast ratio of each text style meets 4.5:1 with the setting on.

## Accessibility

**QOL-47 Real VoiceOver labels.** Annoyance: VoiceOver reads "image" for every photo. Fix: each tile reads its date, place, and favorite state. Rotor actions offer Favorite, Share, and Delete without a drag. Done when VoiceOver reads a label with all three parts on the fixture.

**QOL-48 Dynamic Type and hit targets.** Annoyance: large text clips, and small tiles are hard to tap. Fix: all text scales with Dynamic Type. At accessibility sizes the grid drops a column. Every control has a 44pt target. Done when the largest accessibility size shows no clipped text on the main screens.

## Resilience

**QOL-49 [PhotoKit] Limited access works.** Annoyance: with limited access the app looks empty. Fix: `PermissionState` says how many photos are shared and offers Select More Photos, which opens the system picker. Done when adding photos through the picker updates the grid.

**QOL-50 [PhotoKit] Denied access has a way out.** Annoyance: a denial leaves a dead end. Fix: `PermissionState` explains why access is needed and offers Open Settings. Done when the button opens the app's Settings page.

**QOL-51 Library changes don't jump the scroll.** Annoyance: new photos arriving reset what you were looking at. Fix: inserts animate in and the scroll anchor holds on the visible photo. Done when a new photo above the view leaves the visible tile in place.

**QOL-52 Bounded memory.** Annoyance: a long session slows the phone and eventually crashes. Fix: `ThumbnailCache` caps at 80MB with least-recently-used eviction. Done when a 1,000-item scroll stays under the cap.

**QOL-53 Low Power Mode dials back.** Annoyance: animations drain the battery. Fix: in Low Power Mode, the memory auto-advance stops, the collage stops drifting, and blur-up thumbnails skip the sharpening animation. Done when the three effects are off with Low Power Mode on.

**QOL-54 Offline-first.** Annoyance: the app depends on a connection to show what you already have. Fix: every screen works from local data. Only iCloud downloads need a connection, and their failures appear only on the placeholder. Done when airplane mode leaves all local photos fully browsable.

**QOL-55 Storage pressure.** Annoyance: the app crashes or hangs when the device is nearly full. Fix: the app checks free space before writing caches and drops cache entries first. If space stays low, it shows a single message with what to free up. Done when a simulated low-space state shows the message and the app keeps running.

## Development workflow

**QOL-56 Every item has a test.** Annoyance: fixes regress. Fix: each QOL item ships with a test on `FakeLibrary`, or on `PhotoKitLibrary` for items marked **[PhotoKit]**. Done when the test file for the item exists and passes in CI.

**QOL-57 Screenshots from CI.** Annoyance: Windows means no way to see the UI without a Mac. Fix: the CI job renders key screens on the simulator and uploads them as build artifacts. Done when each main screen has a current screenshot attached to the run.
