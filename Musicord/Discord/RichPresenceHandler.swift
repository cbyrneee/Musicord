//
//  RichPresenceHandler.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import Foundation
import SwiftcordIPC

class RichPresenceHandler : DiscordHandlerDelegate, MediaRemoteHandlerDelegate {
    func register() throws {
        MediaRemoteHandler.shared.delegate = self
        DiscordHandler.shared.delegate = self

        MediaRemoteHandler.shared.register()
    }
    
    func onReady(data: ReadyData) {
        guard let track = MediaRemoteHandler.shared.trackData else {
            return
        }
        
        print("connected")
        self.updatePresence(track: track)
    }
    
    func onTrackDataUpdate(_ data: TrackData) {
        if !DiscordHandler.shared.connected && !DiscordHandler.shared.connecting {
            do {
                try DiscordHandler.shared.register()
                return
            } catch (let error) {
                print(error)
            }
        }
        
        self.updatePresence(track: data)
    }
    
    private func updatePresence(track: TrackData) {
        do {
            try DiscordHandler.shared.setPresence(track: track)
        } catch (let error) {
            // TODO: Error handling
            print(error)
        }
    }
}
