//
//  iTunesLookupResult.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import Foundation

struct iTunesLookupResult : Codable {
    let results: [iTunesLookupItem]
}

struct iTunesLookupItem : Codable {
    public let artworkUrl100: URL?
    public let collectionViewUrl: URL?
}
