//
//  Clipboard_ManagerApp.swift
//  Clipboard Manager
//
//  Created by Akshat on 21/06/25.
//
import SwiftUI

@main
struct ClipboardManagerApp: App {
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @State private var showCopiedToast = false

    var body: some Scene {
        MenuBarExtra("Clipboard", systemImage: "doc.on.clipboard") {
            VStack(spacing: 8) {
                // Toast banner
                if showCopiedToast {
                    Text("Copied!")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .transition(.opacity)
                }

                // Search bar (optional)
                TextField("Search...", text: $clipboardMonitor.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .frame(width: 280)

                Divider()

                // Clipboard entries list
                if clipboardMonitor.filteredHistory.isEmpty {
                    Text("No clipboard entries")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(clipboardMonitor.filteredHistory, id: \.id) { entry in
                                HStack {
                                    Button(action: {
                                        clipboardMonitor.copyToClipboard(entry)
                                        showCopiedToast = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                            showCopiedToast = false
                                        }
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(entry.text)
                                                .lineLimit(2)
                                                .frame(maxWidth: 220, alignment: .leading)

                                            if clipboardMonitor.lastCopiedItemID == entry.id {
                                                Text("✓ Copied")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    Spacer()

                                    Button(action: {
                                        clipboardMonitor.togglePin(entry)
                                    }) {
                                        Image(systemName: entry.pinned ? "star.fill" : "star")
                                            .foregroundColor(entry.pinned ? .yellow : .gray)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)

                                Divider()
                            }
                        }
                        .padding(.top, 4)
                    }
                    .frame(width: 300, height: 300)
                }

                Divider()

                Button("Clear History") {
                    clipboardMonitor.clearHistory()
                }
                .padding(.horizontal)

                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .padding(.horizontal)
            }
            .frame(width: 300)
        }
        .menuBarExtraStyle(.menu)
    }
}
