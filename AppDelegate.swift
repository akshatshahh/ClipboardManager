//
//  AppDelegate.swift
//  Clipboard Manager
//
//  Created by Akshat on 21/06/25.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var clipboardHistory: [String] = []
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Clipboard")
        constructMenu()
        startMonitoringClipboard()
    }

    func constructMenu() {
        let menu = NSMenu()

        if clipboardHistory.isEmpty {
            let noItem = NSMenuItem(title: "No entries yet", action: nil, keyEquivalent: "")
            menu.addItem(noItem)
        } else {
            for (index, entry) in clipboardHistory.prefix(10).enumerated() {
                let item = NSMenuItem(title: entry.prefix(40) + (entry.count > 40 ? "..." : ""), action: nil, keyEquivalent: "")
                item.toolTip = entry
                menu.addItem(item)
            }
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    func startMonitoringClipboard() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let pasteboard = NSPasteboard.general
            if let newString = pasteboard.string(forType: .string), !newString.isEmpty,
               self.clipboardHistory.first != newString {
                self.clipboardHistory.insert(newString, at: 0)
                self.clipboardHistory = Array(self.clipboardHistory.prefix(50))
                self.constructMenu()
            }
        }
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
