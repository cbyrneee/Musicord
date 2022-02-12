//
//  MusicAppHandler.swift
//  Musicord
//
//  Created by Conor Byrne on 12/02/2022.
//

import Foundation
import AppleScriptObjC

protocol MusicAppHandlerDelegate {
    func onTrackDataUpdate()
    func onMusicAppClosed()
}

class MusicAppHandler : ObservableObject {
    static let shared = MusicAppHandler()
    
    public var delegate: MusicAppHandlerDelegate? = nil
    
    @Published
    private(set) var track: TrackData? = nil
        
    private let bridge: MusicBridge
    private let timer: Timer? = nil
    private var wasRunning = false
    
    private init() {
        Bundle.main.loadAppleScriptObjectiveCScripts()
        let clazz: AnyClass = NSClassFromString("MusicBridge")!
        
        self.bridge = clazz.alloc() as! MusicBridge
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTrackData), userInfo: nil, repeats: true)
    }
    
    func isPlaying() -> Bool {
        return bridge.playerState == .playing
    }
    
    @objc
    func updateTrackData() {
        if !bridge.isRunning {
            self.track = nil
            
            if wasRunning {
                delegate?.onMusicAppClosed()
            }
            
            self.wasRunning = bridge.isRunning
            return
        }
        
        self.wasRunning = bridge.isRunning
                
        guard let info = bridge.trackInfo else {
            if self.track == nil {
                return
            }
            
            self.track = nil
            delegate?.onTrackDataUpdate()
            return
        }
                
        guard let artist = info["trackArtist"] as? String else {
            return
        }
        
        guard let name = info["trackName"] as? String else {
            return
        }
        
        guard let album = info["trackAlbum"] as? String else {
            return
        }
        
        let paused = bridge.playerState != .playing
        if name == self.track?.name && artist == self.track?.artist && paused == self.track?.paused {
            return
        }
                
        let cachedResult = iTunesAPI.getCachedSearchResult(term: "\(artist) - \(album)")?.first
        let track = TrackData(
            name: name,
            artist: artist,
            album: album,
            duration: bridge.duration,
            elapsed: bridge.elapsed,
            startTimestamp: Date().timeIntervalSince1970 - (bridge.elapsed),
            albumArt: cachedResult?.artworkUrl100?.absoluteString,
            url: cachedResult?.collectionViewUrl?.absoluteString,
            paused: paused
        )
                
        self.track = track
        delegate?.onTrackDataUpdate()
        
        if cachedResult == nil {
            searchAlbum(track)
        }
    }
    
    private func searchAlbum(_ track: TrackData) {
        iTunesAPI.search(term: "\(track.artist) - \(track.album ?? track.name)") { result in
            switch result {
            case let .success(items):
                guard let item = items.first else {
                    return
                }
                
                var track = self.track
                track?.url = item.collectionViewUrl?.absoluteString
                track?.albumArt = item.artworkUrl100?.absoluteString
                
                DispatchQueue.main.async {
                    self.track = track
                    self.delegate?.onTrackDataUpdate()
                }
            default:
                return
            }
        }
    }
}
