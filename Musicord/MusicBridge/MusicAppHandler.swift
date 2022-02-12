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
}

class MusicAppHandler : ObservableObject {
    static let shared = MusicAppHandler()
    
    public var delegate: MusicAppHandlerDelegate? = nil
    
    @Published
    private(set) var track: TrackData? = nil
        
    private let bridge: MusicBridge
    private let timer: Timer? = nil
    
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
        guard let info = bridge.trackInfo else {
            return
        }
                
        guard let artist = info["trackArtist"] as? String else {
            self.track = nil
            return
        }
        
        guard let name = info["trackName"] as? String else {
            self.track = nil
            return
        }
        
        guard let album = info["trackAlbum"] as? String else {
            self.track = nil
            return
        }
        
        let paused = bridge.playerState != .playing
        if name == self.track?.name && artist == self.track?.artist && album == self.track?.album && paused == self.track?.paused {
            return
        }
        
        let cachedResult = iTunesAPI.getCachedSearchResult(term: album)?.first
        if cachedResult == nil {
            searchAlbum(album)
        }
                
        self.track = TrackData(
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
        
        delegate?.onTrackDataUpdate()
    }
    
    private func searchAlbum(_ album: String) {
        iTunesAPI.searchAlbum(term: album) { result in
            switch result {
            case let .success(items):
                guard let item = items.first else {
                    return
                }
                
                self.track?.url = item.collectionViewUrl?.absoluteString
                self.track?.albumArt = item.artworkUrl100?.absoluteString
                
                DispatchQueue.main.async {
                    self.delegate?.onTrackDataUpdate()
                }
            default:
                return
            }
        }
    }
}
