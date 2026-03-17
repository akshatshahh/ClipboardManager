import SwiftUI

struct ClipboardPopoverView: View {
    @ObservedObject var monitor: ClipboardMonitor

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            searchBar
            Divider().padding(.horizontal, 12)
            clipboardList
            Divider().padding(.horizontal, 12)
            footerSection
        }
        .frame(width: 340, height: 440)
        .background(.ultraThinMaterial)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Clipboard Manager")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            Button {
                NSApp.terminate(nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .help("Quit")
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
            TextField("Search clipboard...", text: $monitor.searchQuery)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
            if !monitor.searchQuery.isEmpty {
                Button {
                    monitor.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    // MARK: - Clipboard List

    private var clipboardList: some View {
        Group {
            if monitor.filteredHistory.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if !monitor.pinnedItems.isEmpty {
                            sectionHeader(
                                title: "Pinned",
                                icon: "pin.fill",
                                count: monitor.pinnedItems.count
                            )
                            ForEach(monitor.pinnedItems) { entry in
                                ClipboardEntryRow(
                                    entry: entry,
                                    isCopied: monitor.lastCopiedItemID == entry.id,
                                    onCopy: { monitor.copyToClipboard(entry) },
                                    onTogglePin: { monitor.togglePin(entry) },
                                    onDelete: { monitor.deleteEntry(entry) }
                                )
                            }
                        }

                        if !monitor.recentItems.isEmpty {
                            sectionHeader(
                                title: "Recent",
                                icon: "clock",
                                count: monitor.recentItems.count
                            )
                            ForEach(monitor.recentItems) { entry in
                                ClipboardEntryRow(
                                    entry: entry,
                                    isCopied: monitor.lastCopiedItemID == entry.id,
                                    onCopy: { monitor.copyToClipboard(entry) },
                                    onTogglePin: { monitor.togglePin(entry) },
                                    onDelete: { monitor.deleteEntry(entry) }
                                )
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clipboard")
                .font(.system(size: 28))
                .foregroundStyle(.quaternary)
            Text(monitor.searchQuery.isEmpty ? "No clipboard entries yet" : "No matching entries")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            if monitor.searchQuery.isEmpty {
                Text("Copy something to get started")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func sectionHeader(title: String, icon: String, count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text("\(title)")
                .font(.system(size: 11, weight: .semibold))
            Text("(\(count))")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            Button {
                monitor.clearHistory()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                    Text("Clear History")
                        .font(.system(size: 12))
                }
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Clears unpinned items")

            Spacer()

            Text("\(monitor.history.count) items")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Entry Row

struct ClipboardEntryRow: View {
    let entry: ClipboardEntry
    let isCopied: Bool
    let onCopy: () -> Void
    let onTogglePin: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button(action: onCopy) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.text)
                        .font(.system(size: 12.5))
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 6) {
                        if isCopied {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 9))
                                Text("Copied")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundStyle(.green)
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            Text(entry.relativeTimestamp)
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isCopied)
                }
            }
            .buttonStyle(.plain)

            Spacer(minLength: 4)

            if isHovered || entry.pinned {
                HStack(spacing: 2) {
                    Button(action: onTogglePin) {
                        Image(systemName: entry.pinned ? "pin.fill" : "pin")
                            .font(.system(size: 11))
                            .foregroundStyle(entry.pinned ? .orange : .secondary)
                            .frame(width: 22, height: 22)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help(entry.pinned ? "Unpin" : "Pin")

                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 22, height: 22)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help("Delete")
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.primary.opacity(0.06) : Color.clear)
                .padding(.horizontal, 6)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
    }
}
