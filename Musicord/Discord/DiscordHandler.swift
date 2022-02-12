//
//  DiscordHandler.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import Foundation
import SwiftcordIPC

enum DiscordHandlerError : Error {
    case notConnected
}

protocol DiscordHandlerDelegate {
    func onReady(data: ReadyData)
}

class DiscordHandler : ObservableObject {
    public static let shared = DiscordHandler()
    private static let clientId = "937029972139327558"
    
    private var ipc: SwiftcordIPC? = nil
    public var delegate: DiscordHandlerDelegate? = nil
    
    public private(set) var connected: Bool = false
    public private(set) var connecting: Bool = false

    @Published var connectionData: ReadyData? = nil

    private init() {}
    
    func register() throws {
        let ipc = SwiftcordIPC(id: DiscordHandler.clientId)
        self.connecting = true

        ipc.onReady = { data in
            DispatchQueue.main.async {
                self.connectionData = data
                self.connected = true
                self.connecting = false
                
                self.delegate?.onReady(data: data)
            }
        }
        
        
        ipc.onDisconnect = {
            self.connected = false
            self.connecting = false
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                try ipc.connectAndBlock()
            } catch {
                // TODO: Error handling
                self.connecting = false
            }
        }
        
        self.ipc = ipc
    }
    
    func disconnect() throws {
        guard let ipc = self.ipc else {
            throw DiscordHandlerError.notConnected
        }
        
        ipc.disconnect()
    }
    
    func setPresence(track: TrackData) throws {
        guard let ipc = self.ipc else {
            throw DiscordHandlerError.notConnected
        }
        
        if track.paused && AppSettings.shared.hideWhenPaused && !connecting {
            ipc.disconnect()
            return
        }
        
        print("[DiscordHandler] Setting presence")

        ipc.setPresence { data in
            data.details = track.name
            data.state = "by \(track.artist)"
            
            if AppSettings.shared.showAlbumArt && track.albumArt != nil {
                data.assets = assets(
                    largeImage: track.albumArt, largeImageText: track.album ?? "Unknown Album",
                    smallImage: track.paused ? "pause" : "play", smallImageText: track.paused ? "Paused" : "Playing"
                )
            }
            
            // We only want to show the track's progress if it's enabled, the track isn't paused, and we have received a duration
            if AppSettings.shared.showTrackProgress && !track.paused && track.duration != 0 {
                let start = track.startTimestamp ?? Date.now.timeIntervalSince1970
                let end = start + track.duration
                
                // Discord doesn't like when start or end is less than or equal to 0
                if start > 0 && end > 0 {
                    data.timestamps = timestamp(start: Int(start), end: Int(end))
                }
            }

            // Only show the song link button if a URL is available and the setting is enabled
            if AppSettings.shared.showSongLinkButton {
                guard let url = track.url else { return }

                data.buttons = [
                    button(label: "Play on Apple Music", url: track.url ?? url)
                ]
            }
        }
    }
}
