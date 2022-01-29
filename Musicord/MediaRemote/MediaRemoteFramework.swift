//
//  MediaRemoteFramework.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import Foundation

enum MediaRemoteFrameworkError : Error {
    case privateFrameworkFailure
}


class MediaRemoteFramework {
    private static let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
    
    public static let nowPlayingInfoDidChangeNotification = NSNotification.Name(rawValue: "kMRMediaRemoteNowPlayingInfoDidChangeNotification")
    public static let isPlayingDidChangeNotification = NSNotification.Name(rawValue: "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification")
    
    private init() {
    }
    
    public static func getPointerForFunction(name: String) throws -> UnsafeMutableRawPointer {
        guard let pointer = CFBundleGetDataPointerForName(bundle, name as NSString) else {
            throw MediaRemoteFrameworkError.privateFrameworkFailure
        }
        
        return pointer
    }
    
    public static func defineFunction<T>(pointer: UnsafeMutableRawPointer) -> T {
        return unsafeBitCast(pointer, to: T.self)
    }
}
