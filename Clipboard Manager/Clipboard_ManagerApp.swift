import SwiftUI

@main
struct ClipboardManagerApp: App {
    @StateObject private var clipboardMonitor = ClipboardMonitor()

    var body: some Scene {
        MenuBarExtra("Clipboard", systemImage: "doc.on.clipboard") {
            ClipboardPopoverView(monitor: clipboardMonitor)
        }
        .menuBarExtraStyle(.window)
    }
}
