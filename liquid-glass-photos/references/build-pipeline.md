# Build pipeline

The owner develops on Windows. Swift does not compile there, and Xcode runs only on macOS. Every iOS build, test run, and `.ipa` comes from GitHub Actions on a macOS runner.

## Contents
- Workflow
- The CI job
- Unsigned .ipa
- Tests and screenshots
- Cost and repo visibility
- Open questions

## Workflow

1. agy edits the Swift project on Windows and commits.
2. The owner pushes to `main` or to a feature branch.
3. The `ios` workflow runs on `macos-latest` (or the pinned image the owner chooses).
4. The job runs tests, builds, packages an unsigned `.ipa`, and uploads artifacts.
5. The owner downloads the `.ipa` and screenshots from the run page.

agy cannot run the build locally. It must not claim a change builds until the CI run passes. If CI fails, agy reads the log and fixes the failure in the same branch.

## The CI job

Outline for `.github/workflows/ios.yml`. Confirm each step against the current runner image before the first run.

- Trigger on `push` and `pull_request`.
- `runs-on: macos-latest`, or a pinned image if the owner wants a fixed Xcode.
- Select the Xcode version. The job must use an Xcode whose SDK includes iOS 27. Check the runner image's installed Xcode list first. If iOS 27 is not available there yet, the build must not silently fall back to an older SDK.
- Cache Swift package resolution keyed on `Package.resolved`.
- Run unit tests on an iPhone simulator. Use a device name present in the image, for example `iPhone 17`. Verify the name against the runner's `xcrun simctl list` output.
- Archive for device with code signing off:

```
xcodebuild -scheme Photos -configuration Release -destination "generic/platform=iOS" -archivePath build/Photos.xcarchive archive CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

- Package the `.app` into an `.ipa`. An `.ipa` is a zip with the app inside a `Payload/` folder:

```
mkdir -p build/Payload && cp -R build/Photos.xcarchive/Products/Applications/*.app build/Payload/ && cd build && zip -r Photos.ipa Payload
```

- Upload `build/Photos.ipa` and the screenshots folder with `actions/upload-artifact`.

## Unsigned .ipa

The `.ipa` from this job is unsigned. It cannot be installed directly on a device. Installing it needs re-signing with a certificate and provisioning profile on the owner's side. Signing material is secret and stays out of the repo.

Signing and installation are a separate decision that is not made yet. Do not add signing to this workflow until the owner chooses a path. Options to evaluate later: a free Apple ID through a sideload tool, a paid developer account with TestFlight, or nothing until a release is ready.

## Tests and screenshots

- Unit tests cover each QOL item on `FakeLibrary`, and on `PhotoKitLibrary` where marked.
- A UI test target captures the main screens (Library, viewer, For You, Albums, Search) for QOL-57. Attach each screenshot to the test results and copy them to the artifact folder.
- Failed screenshots still upload, so the owner can see what broke.

## Cost and repo visibility

GitHub-hosted macOS runners cost more minutes than Linux runners. Public repositories receive standard GitHub-hosted runner minutes at no charge, which is the reason this project is public. Confirm current GitHub policy before relying on it, and keep the repo public while the free tier covers the builds.

Keep the workflow lean: one build job, one test job, caching on. Skip the archive step on pull requests if build time becomes a problem, and keep it on `main`.

## Open questions

These are open. Ask the owner before deciding any of them.

1. **Deployment target:** iOS 27 minimum, as assumed in `SKILL.md`. Confirm.
2. **Xcode and SDK availability:** whether the runner image has an iOS 27 SDK yet. If not, the owner decides whether to wait or to build against the newest available SDK.
3. **License:** pick one before the first public commit.
4. **App name:** "Photos" is a working title. Using Apple's name in a product is a trademark issue, so pick a distinct name before any release.
5. **Signing path:** see Unsigned .ipa above.
6. **Light mode:** the design is dark-only for now. Decide whether a light variant is in scope.
