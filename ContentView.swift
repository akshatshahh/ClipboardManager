//
//  ContentView.swift
//  Clipboard Manager
//
//  Created by Akshat on 21/06/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var history: [String] = []
    @State private var lastChangeCount = NSPasteboard.general.changeCount
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 12) {
            Text("Clipboard History")
                .font(.title2)
                .bold()
                .padding(.top)

            List(history, id: \.self) { item in
                Text(item)
                    .lineLimit(3)
                    .padding(.vertical, 4)
                    .contextMenu {
                        Button("Copy Again") {
                            let pb = NSPasteboard.general
                            pb.clearContents()
                            pb.setString(item, forType: .string)
                        }
                    }
            }
        }
        .padding()
        .frame(width: 400, height: 500)
        .onAppear {
            // Start monitoring clipboard every 2 seconds
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                let pasteboard = NSPasteboard.general
                if pasteboard.changeCount != lastChangeCount {
                    lastChangeCount = pasteboard.changeCount
                    if let newText = pasteboard.string(forType: .string), !newText.isEmpty {
                        if history.first != newText {
                            history.insert(newText, at: 0)  // insert at top
                            // Keep only last 50 items
                            if history.count > 50 {
                                history.removeLast()
                            }
                        }
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

#Preview {
    ContentView()
}

