//
//  AppSettings.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import SwiftUI

class AppSettings : ObservableObject {
    public static let shared = AppSettings()
    
    @AppStorage("hideWhenPaused") public var hideWhenPaused = false
    @AppStorage("showTrayIcon") public var showTrayIcon = true

    @AppStorage("showAlbumArt") public var showAlbumArt = true
    @AppStorage("showTrackProgress") public var showTrackProgress = true
    @AppStorage("showSongLinkButton") public var showSongLinkButton = true

    private init() {
    }
}
