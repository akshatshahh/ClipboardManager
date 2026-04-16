# Clipboard Manager for macOS

A lightweight, native macOS menu bar clipboard manager built with SwiftUI. It silently monitors your clipboard, keeps a searchable history, and lets you pin frequently used items for quick access.

## Features

- **Menu bar app** -- lives in your menu bar, no Dock icon, always one click away
- **Clipboard history** -- automatically captures up to 50 recent text copies
- **Pin items** -- pin frequently used snippets so they stay at the top and survive clears
- **Search** -- instantly filter your clipboard history
- **One-click copy** -- click any entry to copy it back to your clipboard
- **Delete individual items** -- remove entries you don't need
- **Relative timestamps** -- see when each item was copied ("just now", "2m ago", "1h ago")
- **Frosted glass UI** -- modern macOS design with material backgrounds and hover effects
- **Persistent storage** -- history survives app restarts (stored in UserDefaults)

## Download

The easiest way to get the app — no GitHub account required:

1. Go to the [**Releases**](../../releases/latest) page of this repository.
2. Under *Assets*, download **Clipboard-Manager-macos.zip**.
3. Unzip it, move **Clipboard Manager.app** to your Applications folder (or anywhere you like), and open it.
4. On first launch macOS may show a security warning — **right-click the app → Open**, then click **Open** in the dialog.

> The release is rebuilt and published automatically on every push to `main`, so it always reflects the latest code.

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15 or later (only if building locally)

## Build in the cloud (no Xcode required)

The repo includes a **GitHub Actions** workflow that builds the app on GitHub’s macOS runners. You don’t need Xcode installed.

1. Push this project to a GitHub repo (or fork it).
2. Open the **Actions** tab and run the **Build macOS app** workflow (or push to `main`/`master` to trigger it).
3. When the run finishes, a **Latest Build** GitHub Release is created/updated automatically with the zip attached.
4. Unzip locally, move **Clipboard Manager.app** to Applications (or leave it anywhere), and open it.  
   On first launch, if macOS blocks it: **right-click the app → Open**, then confirm.

## Build from Source (Xcode)

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd ClipboardManager
   ```

2. Open in Xcode:
   ```bash
   open "Clipboard Manager.xcodeproj"
   ```

3. Select your signing team in **Signing & Capabilities** (your personal team works fine for local builds).

4. Press **Cmd+R** to build and run. The clipboard icon will appear in your menu bar.

## Distribution

### Option A: Share as ZIP (no Developer account needed)

1. In Xcode, go to **Product > Archive**.
2. In the Organizer, click **Distribute App > Copy App**.
3. Compress the `.app` into a `.zip` and share it.
4. Recipients need to right-click the app > **Open** on first launch to bypass Gatekeeper.

### Option B: Create a DMG (recommended)

1. Build the archive as above and export the `.app`.
2. Create a DMG:
   ```bash
   hdiutil create -volname "Clipboard Manager" \
     -srcfolder "Clipboard Manager.app" \
     -ov -format UDZO \
     "ClipboardManager.dmg"
   ```
3. For notarization (requires Apple Developer account, $99/year):
   ```bash
   xcrun notarytool submit ClipboardManager.dmg \
     --apple-id YOUR_APPLE_ID \
     --team-id YOUR_TEAM_ID \
     --password YOUR_APP_SPECIFIC_PASSWORD \
     --wait
   xcrun stapler staple ClipboardManager.dmg
   ```

### Option C: Mac App Store

Submit via Xcode's Organizer to App Store Connect. Requires an Apple Developer account and review.

## Usage

1. The app runs as a menu bar icon (clipboard icon in the top-right of your screen).
2. **Copy anything** -- text you copy is automatically captured.
3. **Click the menu bar icon** to see your history.
4. **Click an entry** to copy it back to your clipboard.
5. **Pin entries** by clicking the pin icon -- pinned items stay at the top.
6. **Search** by typing in the search bar.
7. **Delete entries** by hovering and clicking the X button.
8. **Clear History** removes all unpinned items.

## License

MIT
