//
//  ClipboardMonitor.swift
//  Clipboard Manager
//
//  Created by Akshat on 21/06/25.
//


import Foundation
import AppKit

class ClipboardMonitor: ObservableObject {
    @Published var history: [ClipboardEntry] = []
    @Published var lastCopiedItemID: UUID?
    @Published var searchQuery: String = ""

    private var lastChangeCount = NSPasteboard.general.changeCount
    private var timer: Timer?
    private let historyKey = "ClipboardHistory"
    private var skipNextPasteboardChange = false

    init() {
        loadHistory()
        startMonitoring()
    }

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let pasteboard = NSPasteboard.general
            if pasteboard.changeCount != self.lastChangeCount {
                self.lastChangeCount = pasteboard.changeCount

                guard !self.skipNextPasteboardChange else {
                    self.skipNextPasteboardChange = false
                    return
                }

                if let copiedString = pasteboard.string(forType: .string),
                   !copiedString.isEmpty,
                   copiedString != self.history.first?.text {

                    let newEntry = ClipboardEntry(text: copiedString)

                    DispatchQueue.main.async {
                        self.history.insert(newEntry, at: 0)
                        self.history = Array(self.history.prefix(50))
                        self.saveHistory()
                    }
                }
            }
        }
    }

    func copyToClipboard(_ entry: ClipboardEntry) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(entry.text, forType: .string)
        lastCopiedItemID = entry.id
        skipNextPasteboardChange = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.lastCopiedItemID == entry.id {
                self.lastCopiedItemID = nil
            }
        }
    }

    func togglePin(_ entry: ClipboardEntry) {
        if let index = history.firstIndex(where: { $0.id == entry.id }) {
            history[index].pinned.toggle()
            reorderHistory()
            saveHistory()
        }
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    private func reorderHistory() {
        history.sort { ($0.pinned ? 0 : 1, $0.id.uuidString) < ($1.pinned ? 0 : 1, $1.id.uuidString) }
    }

    private func saveHistory() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ClipboardEntry].self, from: data) {
                history = decoded
                reorderHistory()
            }
        }
    }

    deinit {
        timer?.invalidate()
    }

    var filteredHistory: [ClipboardEntry] {
        if searchQuery.isEmpty {
            return history
        } else {
            return history.filter { $0.text.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
}
