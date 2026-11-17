# Design system

Source docs: Apple (dark hardware gallery), monopo saigon (monochrome editorial with one iridescent moment), and Craft (warm scrapbook, serif headlines). Apple is the base. monopo sets the restraint. Craft contributes one serif accent. Where the sources conflict, the resolution table at the end wins.

## Contents
- Colors
- Typography
- Shape and spacing
- Glass and elevation
- Motion
- Accessibility fallbacks
- Source conflicts and resolutions

## Colors

| Token | Hex | Use |
|---|---|---|
| `obsidian` | `#000000` | App canvas, viewer background, memory stage base |
| `graphite` | `#0E0E0E` | Chrome surfaces behind glass, fallback when Reduce Transparency is on |
| `carbon` | `#1D1D1F` | Sheets and info panels |
| `steel` | `#333336` | Hairline borders, segmented control track |
| `slate` | `#6E6E73` | Outlines, disabled controls |
| `ash` | `#86868B` | Secondary text, month headers, metadata |
| `porcelain` | `#F5F5F7` | Primary text on dark |
| `white` | `#FFFFFF` | Icons and high-contrast text |
| `appleBlue` | `#0071E3` | Selection check mark, one primary action per screen |
| `electricLink` | `#2997FF` | Text links and tappable labels such as "Select" and "Cancel" |
| `destructive` | `#FF453A` | Delete and other destructive text. Not in the source docs; added for iOS convention |
| `iridescentFade` | `linear-gradient(90deg, #A0E0AB, #FFAC2E 50%, #A52D25)` | Memory hero backdrop only |

Rules:
- Text is `porcelain`. Secondary text is `ash`. Never use pure `#000` for text.
- Never use color for decoration on UI controls. Color means state (selected, favorited, destructive) or action (primary, link).
- The favorite heart is `#FF453A` when filled. This is a state color, not a brand color.

## Typography

Use system fonts. Do not bundle fonts.

- Body, UI, and labels: SF Pro (system default, `.body` and related Dynamic Type styles).
- Memory titles only: New York via `.fontDesign(.serif)`. This is the iOS serif, and it stands in for Craft's `UntitledSerifFont`. Use it for titles at 24pt or larger. Never use it for controls or body text.

Type scale (Dynamic Type styles, with the source values as the default size):

| Role | Style | Default size | Weight | Tracking |
|---|---|---|---|---|
| Large title | `.largeTitle` | 34 | bold | -0.022em |
| Section title | `.title2` | 22 | semibold | -0.01em |
| Headline | `.headline` | 17 | semibold | normal |
| Body | `.body` | 17 | regular | normal |
| Footnote | `.footnote` | 13 | regular | normal |
| Caption | `.caption2` | 11 | semibold | 0.01em |
| Memory title | `.largeTitle`, serif | 44 | regular | -0.02em |
| Memory subtitle | `.body` | 15 | regular | normal |

Rules:
- Every text style must scale with Dynamic Type. No fixed point sizes for text.
- Numbers use monospaced digits where they change, such as timers and counters.
- Line height 1.2 for titles, 1.4 for body.

## Shape and spacing

Base unit: 4pt.

Spacing scale: 4, 8, 12, 16, 20, 24, 32, 48. Page gutters are 16pt. Section gaps are 24pt.

Radii:

| Element | Radius |
|---|---|
| Grid photo tile | 0 (square, edge to edge, 2pt gutter) |
| Memory stage, sheets, feature panels | 28 |
| Buttons, chips, search field, glass pills | capsule (full pill) |
| Text links | none |
| Album stack layers | 16 |
| Collage cards in memories | 18 |

Monopo's rule that cards use 0 radius applies to photo tiles here. Apple's 28pt media radius applies to the memory stage and panels. The rule that buttons are pills comes from monopo and Apple.

## Glass and elevation

Liquid Glass is the material for floating chrome. Shadows are not used.

- Use the iOS 27 glass APIs for floating chrome. Confirm the exact API names against the iOS 27 SDK at build time. Do not assume names from memory. The iOS 26 surface, which may change, is `glassEffect(_:in:)`, `GlassEffectContainer`, `glassEffectID(_:in:)`, and `.buttonStyle(.glass)`.
- Group nearby glass elements in one container so they blend and morph together. The tab bar lens and the selection bar are examples.
- Glass sits on top of content. It never sits on a photo's own pixels except for the viewer chrome, which floats over the photo.
- No drop shadows anywhere in the app. Separation comes from glass, hairline `steel` borders at 1pt, and color shifts between `obsidian`, `graphite`, and `carbon`.

## Motion

Two curves:

- **Spring** for taps and state changes: response 0.3s, damping fraction 0.75. Used for button presses, chip selection, tile selection, and favorites.
- **Smooth ease-out** for transitions between screens and the viewer open and close: the curve `cubic-bezier(0.19, 1, 0.22, 1)` over 0.6 to 0.8s. Monopo's 1.25s is too slow for taps, so it is reserved for the For You story transition.

Rules:
- Motion is transform and opacity first. Avoid animating layout where a transform works.
- The tab bar lens squishes by about 16% horizontally for 0.45s as it moves, which gives it liquid feel.
- Nothing should snap. Every state change has a transition.
- With Reduce Motion on, replace springs and zooms with a 0.2s crossfade. The memory stories still advance, but they fade.

## Accessibility fallbacks

- **Reduce Transparency:** glass becomes a solid `graphite` fill with a 1pt `steel` border.
- **Increase Contrast:** `ash` text becomes `porcelain`, and hairlines become 2pt.
- **Reduce Motion:** see Motion above.
- **Dynamic Type:** at accessibility sizes, grids drop one column and month headers stack the count under the title.
- **Hit targets:** 44pt minimum. Grid tiles at the densest zoom still need a 44pt tap area, so the tile is the target, not the visual.

## Source conflicts and resolutions

| Question | Apple says | monopo says | Craft says | Resolution |
|---|---|---|---|---|
| Blue on controls | Blue for Buy and Learn More | No chromatic UI color | Azure for icons in mockups | Blue only for the selection check and one primary action per screen. Owner to confirm. |
| Image corners | 28px | 0px on images | 14 to 24px on cards | Photo tiles 0px. Memory stage and panels 28px. |
| Shadows | Almost none, 1px keylines | None | Deep multi-layer | None. Glass provides depth. |
| Serif | Not used | Not used | Headlines only, 24px+ | Memory titles only, New York serif. |
| Canvas color | `#000` | White | Warm `#FFF3E7` | Obsidian. Warm canvas is off-brand for a photo app. |
| Iridescence | None | One hero only | None | Memory hero only, one per screen. |
| Motion timing | Not specified | 0.8 to 1.25s, cubic-bezier | Not specified | Taps use springs. Screen transitions use monopo's curve at 0.6 to 0.8s. |

If the owner changes any resolution, update this table and the rule it affects in `SKILL.md`.
