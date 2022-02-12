//
//  SettingsView.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import SwiftUI
import LaunchAtLogin

struct AppearanceSettingsView : View {
    @ObservedObject private var settings = AppSettings.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Section {
                Toggle("Show album art", isOn: settings.$showAlbumArt)
                Toggle("Show track progress", isOn: settings.$showTrackProgress)
                Toggle("Show song link button", isOn: settings.$showSongLinkButton)
            }
        }
    }
}

struct GeneralSettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var statusIconWarning = false
    
    var body: some View {
        VStack(alignment: .center) {
            Form {
                Section {
                    LaunchAtLogin.Toggle()
                    Toggle("Hide when paused", isOn: settings.$hideWhenPaused)
                    Toggle("Show status bar icon", isOn: settings.$showTrayIcon)
                }
            }
        }
        .alert("Status Icon Hidden", isPresented: $statusIconWarning, actions: {}) {
            Text("To open the preferences window again, re-open the application via Finder or Launchpad.")
        }
        .onChange(of: settings.showTrayIcon) { newValue in
            AppDelegate.shared?.statusItem?.isVisible = newValue
            if !newValue {
                statusIconWarning = true
            }
        }
    }
}

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, appearance
    }
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
                .tag(Tabs.appearance)
        }
        .padding(20)
        
        Button {
            guard let track = MusicAppHandler.shared.track else {
                return
            }
            
            do {
                try DiscordHandler.shared.setPresence(track: track)
            } catch {}
        } label: {
            Text("Force Presence Update")
        }
        .padding(.top)
        
        Text("Some settings will be applied when your song changes")
            .padding(.top, 1)
            .font(.subheadline)
    }
}
