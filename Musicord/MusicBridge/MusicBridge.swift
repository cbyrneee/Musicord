//
//  Support.swift
//  Swift-AppleScriptObjC
//

import Cocoa

@objc(NSObject)
protocol MusicBridge {
    var _isRunning: NSNumber { get }
    var _playerState: NSNumber { get }
    
    var trackInfo: [NSString:AnyObject]? { get }
    var trackDuration: NSNumber { get }
    var trackElapsed: NSNumber { get }
}


extension MusicBridge {
    var isRunning: Bool { return self._isRunning.boolValue }
    var playerState: PlayerState { return PlayerState(rawValue: self._playerState as! Int)! }
    
    var duration: Double { return Double(truncating: trackDuration) }
    var elapsed: Double { return Double(truncating: trackElapsed) }
}


@objc
enum PlayerState: Int {
    case unknown
    case stopped
    case playing
    case paused
    case fastForwarding
    case rewinding
}

