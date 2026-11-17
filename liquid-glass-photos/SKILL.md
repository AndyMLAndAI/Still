---
name: liquid-glass-photos
description: Spec, design system, components, QoL fixes, and iOS build pipeline for a hyperminimal, ultra-interactive iOS Photos-style app built with iOS 27 Liquid Glass. Use this whenever the user is planning, specifying, reviewing, or extending this photos app, asks about its screens (Library, For You, Albums, Search), its components, design tokens, Liquid Glass usage, selection, deletion, undo, haptics, or quality-of-life behavior, its Windows-to-.ipa build through GitHub Actions, or hands work to Antigravity (agy). Also use for any new screen or component in this project, even if the user never says "skill" or "photos app".
---

# Liquid Glass Photos

A spec and design system for a native iOS Photos-style app. Antigravity (agy) writes the code. Claude writes specs, reviews agy's output, and answers design questions.

## Roles (non-negotiable)

- **Claude** writes and revises specs in this skill, reviews what agy produces, and answers questions. Claude does not produce HTML, JavaScript, React, or any other mockup or prototype of this app, including "quick previews". If the user asks for a visual, write the spec for it and hand it to agy.
- **agy (Antigravity)** writes all app code in Swift and SwiftUI.
- **The owner (Andy)** works on a Windows laptop with no Mac. He cannot run Xcode, so every iOS build happens in GitHub Actions.

## What the app is

A hyperminimal photo app in the spirit of iOS Photos, but deliberately not boring. It has four screens (Library, For You, Albums, Search), a photo viewer, multi-select, and floating Liquid Glass chrome. It is fully interactive and built around fixing the small annoyances people put up with in the stock Photos app. The full list is in `references/qol.md`.

The project is open source on GitHub from the first commit.

## Hard rules

1. **Native SwiftUI, iOS 27 minimum, iPhone first.** Confirm the deployment target before the first commit.
2. **One component per file.** Each visible piece of UI is its own type, named after what it shows (see `references/components.md`). Each has a preview that runs on `FakeLibrary`.
3. **Liquid Glass only on floating chrome:** the tab bar, selection bar, viewer bars, toasts, info sheet, and pill buttons. Never put glass on photos, tiles, memory art, or body text.
4. **Monochrome interface.** Text and chrome use Obsidian, Porcelain, and Ash. Apple Blue (`#0071e3`) appears only on the selection check mark and on one primary action per screen. No other chromatic UI color. The iridescent gradient appears only as the For You hero backdrop.
5. **The UI never tints itself from photo content.** No color extraction from images.
6. **Every action that changes the library or the user's data has a visible result.** Either an Undo toast or a clear system confirmation. See QOL-07 through QOL-10 for the PhotoKit constraint.
7. **Accessibility is part of the feature.** Dynamic Type, VoiceOver labels on every control, 44pt minimum hit targets, Reduce Motion, Reduce Transparency, and Increase Contrast all have defined fallbacks in `references/design-system.md`.
8. **Works without a real library.** Everything runs against a `MediaLibrary` protocol with a `FakeLibrary` implementation. The PhotoKit adapter is a separate implementation of the same protocol.
9. **No third-party UI libraries.** Use system components and SwiftUI. Add no network calls. The only optional network feature allowed later is iCloud data that the system already provides.
10. **Open source from day one.** Commit a README and a LICENSE. The license is the owner's choice. Ask before picking one. Never commit secrets, signing certificates, or provisioning profiles.

## Build order for agy

Work through these phases in order. Each phase ends with passing tests in CI.

1. **Foundation:** `MediaLibrary` protocol, `FakeLibrary` with about 200 generated assets across three months, design tokens, and the empty app shell.
2. **Library:** `PhotoGrid`, `PhotoTile`, `MonthHeader`, `ZoomSegmented`, zoom levels, and pinch to zoom.
3. **Viewer:** `PhotoViewer`, its chrome, swipe, dismiss, and the zoom-from-tile transition.
4. **Selection and recovery:** `SelectionBar`, long-press, drag-select, `ToastGlass` with Undo.
5. **For You, Albums, Search:** `MemoryStage`, `AlbumCard`, `SearchField`, `SearchChips`.
6. **PhotoKit adapter:** real library access, limited-access handling, and iCloud placeholders.
7. **CI:** the GitHub Actions workflow in `references/build-pipeline.md`, producing an unsigned `.ipa`.
8. **QoL pass:** go through `references/qol.md` one item at a time. Each item needs its own test and fixture.

## Reference files

Read only what the task needs.

- `references/design-system.md`: colors, type, radii, spacing, motion, Liquid Glass usage, and the rules for resolving conflicts between the three source design docs. Read before any visual or styling work.
- `references/components.md`: the component inventory with purpose, states, and interactions. Read before creating or naming any component.
- `references/qol.md`: about 55 quality-of-life items, each with the problem, the fix, and a done-when check. Read before any feature or polish work, and when the user asks for QoL ideas.
- `references/build-pipeline.md`: Windows workflow, the GitHub Actions macOS job, unsigned `.ipa` packaging, and open questions. Read for anything involving CI, signing, or the `.ipa`.

## Working with the owner

- Keep answers short and concrete. The owner gets specs faster than prose.
- When a decision is open, say what it is and give a recommendation. Do not just list options.
- When agy's output contradicts this skill, point to the rule number and ask agy to fix it. Do not silently accept a deviation.
- Treat changes to the rules in this file as decisions. Record the reason in the change.
