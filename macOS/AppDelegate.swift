//
//  AppDelegate.swift
//  Xcode13_2 (macOS)
//
//  Created by Marcelo Gobetti on 16/12/21.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 950, height: 600),
            styleMask: [.miniaturizable, .closable, .resizable, .titled],
            backing: .buffered,
            defer: false)
        window?.setFrameAutosaveName("Main Window")
        window?.contentView = NSHostingView(rootView: CharactersView())
        window?.title = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
        window?.isMovableByWindowBackground = true
        window?.tabbingMode = .disallowed
        window?.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
