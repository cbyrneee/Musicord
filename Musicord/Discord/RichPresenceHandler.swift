//
//  RichPresenceHandler.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import Foundation
import SwiftcordIPC

class RichPresenceHandler : DiscordHandlerDelegate, MusicAppHandlerDelegate {
    func register() throws {
        MusicAppHandler.shared.delegate = self
        DiscordHandler.shared.delegate = self

        try DiscordHandler.shared.register()
    }
    
    func onReady(data: ReadyData) {
        print("[RichPresenceHandler] Ready!")
        self.updatePresence()
    }
    
    func onTrackDataUpdate() {
        if !DiscordHandler.shared.connected && !DiscordHandler.shared.connecting {
            do {
                try DiscordHandler.shared.register()
                return
            } catch (let error) {
                print(error)
            }
        }
        
        print("[RichPresenceHandler] Track data updated")
        self.updatePresence()
    }
    
    func onMusicAppClosed() {
        print("[RichPresenceHandler] Music app closed")

        do {
            try DiscordHandler.shared.clearPresence()
        } catch (let error) {
            print(error)
        }
    }
    
    private func updatePresence() {
        do {
            guard let track = MusicAppHandler.shared.track else {
                try DiscordHandler.shared.clearPresence()
                return
            }
            
            try DiscordHandler.shared.setPresence(track: track)
        } catch (let error) {
            // TODO: Error handling
            print(error)
        }
    }
}
