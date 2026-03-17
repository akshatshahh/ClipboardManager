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
                   copiedString != self.history.first(where: { !$0.pinned })?.text {

                    let newEntry = ClipboardEntry(text: copiedString)

                    DispatchQueue.main.async {
                        self.history.removeAll { !$0.pinned && $0.text == copiedString }
                        self.history.append(newEntry)
                        let unpinnedCount = self.history.filter { !$0.pinned }.count
                        if unpinnedCount > 50 {
                            if let oldest = self.history.first(where: { !$0.pinned }) {
                                self.history.removeAll { $0.id == oldest.id }
                            }
                        }
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.lastCopiedItemID == entry.id {
                self.lastCopiedItemID = nil
            }
        }
    }

    func togglePin(_ entry: ClipboardEntry) {
        if let index = history.firstIndex(where: { $0.id == entry.id }) {
            history[index].pinned.toggle()
            saveHistory()
        }
    }

    func deleteEntry(_ entry: ClipboardEntry) {
        history.removeAll { $0.id == entry.id }
        saveHistory()
    }

    func clearHistory() {
        history.removeAll { !$0.pinned }
        saveHistory()
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
            }
        }
    }

    deinit {
        timer?.invalidate()
    }

    var pinnedItems: [ClipboardEntry] {
        let pinned = history.filter { $0.pinned }
        if searchQuery.isEmpty { return pinned }
        return pinned.filter { $0.text.localizedCaseInsensitiveContains(searchQuery) }
    }

    var recentItems: [ClipboardEntry] {
        let recent = history
            .filter { !$0.pinned }
            .sorted { $0.createdAt > $1.createdAt }
        if searchQuery.isEmpty { return recent }
        return recent.filter { $0.text.localizedCaseInsensitiveContains(searchQuery) }
    }

    var filteredHistory: [ClipboardEntry] {
        return pinnedItems + recentItems
    }
}
