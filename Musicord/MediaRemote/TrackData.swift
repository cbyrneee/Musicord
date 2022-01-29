//
//  TrackData.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import Foundation

struct TrackData {
    let name, artist: String
    let album: String?
    let duration, elapsed: Double
    let startTimestamp: Double?
    let albumArt: String?
    let url: String?
    let paused: Bool
}
