//
//  MRPlaybackState.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import Foundation

enum MRPlaybackState: Int {
    case unknown = 0
    case playing, paused, stopped, interrupted
}
