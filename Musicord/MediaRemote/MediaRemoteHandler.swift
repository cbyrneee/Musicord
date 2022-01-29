//
//  MediaRemoteHandler.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import Foundation

protocol MediaRemoteHandlerDelegate {
    func onTrackDataUpdate(_ data: TrackData)
}

class MediaRemoteHandler : ObservableObject {
    public static let shared = try! MediaRemoteHandler()
    
    public var delegate: MediaRemoteHandlerDelegate? = nil

    private let getNowPlayingInfo: @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    private let registerForNowPlayingNotifications: @convention(c) (DispatchQueue) -> Void
    private let getNowPlayingApplicationPlaybackState: @convention(c) (DispatchQueue, @escaping (Int) -> Void) -> Void

    @Published public var trackData: TrackData? = nil {
        didSet {
            print("didSet")
            guard let data = trackData else {
                return
            }
            
            self.delegate?.onTrackDataUpdate(data)
        }
    }
    
    private init() throws {
        let getNowPlayingInfoPointer = try MediaRemoteFramework.getPointerForFunction(name: "MRMediaRemoteGetNowPlayingInfo")
        self.getNowPlayingInfo = MediaRemoteFramework.defineFunction(pointer: getNowPlayingInfoPointer)

        let registerForNotificationsPointer = try MediaRemoteFramework.getPointerForFunction(name: "MRMediaRemoteRegisterForNowPlayingNotifications")
        self.registerForNowPlayingNotifications = MediaRemoteFramework.defineFunction(pointer: registerForNotificationsPointer)
        
        let getNowPlayingApplicationPlaybackStatePointer = try MediaRemoteFramework.getPointerForFunction(name: "MRMediaRemoteGetNowPlayingApplicationPlaybackState")
        self.getNowPlayingApplicationPlaybackState = MediaRemoteFramework.defineFunction(pointer: getNowPlayingApplicationPlaybackStatePointer)
    }
    
    public func register() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNowPlayingInformation),
            name: MediaRemoteFramework.nowPlayingInfoDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNowPlayingInformation),
            name: MediaRemoteFramework.isPlayingDidChangeNotification,
            object: nil
        )
        
        registerForNowPlayingNotifications(DispatchQueue.main)
        updateNowPlayingInformation()
    }
        
    @objc func updateNowPlayingInformation() {
        getNowPlayingInfo(DispatchQueue.main) { information in
            // We only want to show information for Apple Music, this key is only present when using Apple Music (usually)
            if let isMusicApp = information["kMRMediaRemoteNowPlayingInfoIsMusicApp"] as? Bool {
                if !isMusicApp {
                    return
                }
            } else {
                return
            }
                                    
            guard let title = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String else { return }
            guard let artist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String else { return }
            
            let album = information["kMRMediaRemoteNowPlayingInfoAlbum"] as? String
            let timestamp = information["kMRMediaRemoteNowPlayingInfoTimestamp"] as? Date
            let elapsed = information["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double ?? 0
            let duration = information["kMRMediaRemoteNowPlayingInfoDuration"] as? Double ?? 0
        
            self.getNowPlayingApplicationPlaybackState(DispatchQueue.global()) { state in
                let state = MRPlaybackState(rawValue: state)
                let fallback = {
                    DispatchQueue.main.async {
                        self.trackData = TrackData(
                            name: title,
                            artist: artist,
                            album: album,
                            duration: duration,
                            elapsed: elapsed,
                            startTimestamp: timestamp?.timeIntervalSince1970,
                            albumArt: nil,
                            url: nil,
                            paused: state == .paused
                        )
                    }
                }
                               
                let storeIdentifier = information["kMRMediaRemoteNowPlayingInfoiTunesStoreIdentifier"] as? Int ?? 0
                if storeIdentifier == 0 {
                    fallback()
                    return
                }
                
                // We use the iTunes API to get album art for a track
                iTunesAPI.lookup(id: storeIdentifier) { result in
                    switch result {
                    case let .success(data):
                        if data.isEmpty {
                            fallback()
                            return
                        }
                        
                        let artwork = data.first?.artworkUrl100?.absoluteString.replacingOccurrences(of: "100x100", with: "300x300")
                        let url = data.first?.collectionViewUrl?.absoluteString
                        
                        DispatchQueue.main.async {
                            self.trackData = TrackData(
                                name: title,
                                artist: artist,
                                album: album,
                                duration: duration,
                                elapsed: elapsed,
                                startTimestamp: timestamp?.timeIntervalSince1970,
                                albumArt: artwork,
                                url: url,
                                paused: state == .paused
                            )
                        }
                    case .failure(let error):
                        switch error {
                        case iTunesAPIError.alreadyFetching:
                            return
                        default:
                            fallback()
                        }
                        return
                    }
                }
            }
        }
    }
}
