//
//  MusicordApp.swift
//  Musicord
//
//  Created by Conor Byrne on 29/01/2022.
//

import SwiftUI
import AppKit
import SwiftcordIPC

@main
struct MusicordApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            SettingsView()
                .frame(width: 350, height: 200)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    static private(set) var shared: AppDelegate? = nil
    
    let menu = NSMenu()
    let application = NSApplication.shared
    let richPresenceHandler = RichPresenceHandler()
    
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self

        setupStatusItem()
        setupMenu()
                
        do {
            try richPresenceHandler.register()
        } catch (let error) {
            // TODO: Error handling
            print(error)
        }
    }
        
    func applicationDidBecomeActive(_ notification: Notification) {
        if !AppSettings.shared.showTrayIcon {
            showPreferences()
        }
    }
    
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // TODO: Change to non-fill when not connected to Discord
        statusItem?.button?.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Musicord")
        statusItem?.menu = menu
        statusItem?.isVisible = AppSettings.shared.showTrayIcon
    }
    
    func setupMenu() {
        menu.delegate = self

        let userViewItem = NSMenuItem()
        userViewItem.target = self
        userViewItem.view = createUserView()
        menu.addItem(userViewItem)
        menu.addItem(.separator())

        let preferencesItem = NSMenuItem(title: "Preferences", action: #selector(showPreferences), keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)
        
        let quitItem = NSMenuItem(title: "Quit Musicord", action: #selector(quitApplication), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    func createUserView() -> NSHostingView<UserView> {
        let contentView = UserView()
        let hostView = NSHostingView(rootView: contentView)
        hostView.frame = NSRect(x: 0, y: 0, width: 200, height: 175)

        return hostView
    }
    
    @objc func showPreferences() {
        // Ultimate hax to show the nice looking preferences window
        application.activate(ignoringOtherApps: true)
        application.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        
        // Windows 11 reference
        for window in application.windows {
            window.center()
        }
    }

    @objc func quitApplication() {
        self.application.terminate(self)
    }
}
