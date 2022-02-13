//
//  RichPresenceHandler.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import Foundation
import SwiftcordIPC

class RichPresenceHandler : DiscordHandlerDelegate, MusicAppHandlerDelegate {
    private var retryTimer: Timer? = nil
    private var retryAttempts = 0
    
    @objc
    func register() {
        print("[RichPresenceHandler] Attempting to connect...")
        
        MusicAppHandler.shared.delegate = self
        DiscordHandler.shared.delegate = self

        DiscordHandler.shared.register { error in
            if self.retryTimer == nil {
                self.retryTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.register), userInfo: nil, repeats: true)
            }
        }
    }
    
    func onReady(data: ReadyData) {
        print("[RichPresenceHandler] Ready!")
        
        self.resetTimer()
        self.updatePresence()
    }
    
    func onTrackDataUpdate() {
        if !DiscordHandler.shared.connected && !DiscordHandler.shared.connecting {
            register()
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
    
    private func resetTimer() {
        self.retryAttempts = 0
        self.retryTimer?.invalidate()
        self.retryTimer = nil
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
