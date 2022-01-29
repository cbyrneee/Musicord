//
//  TrackView.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import SwiftUI
import SwiftcordIPC
import CachedAsyncImage

struct TrackView: View {
    @ObservedObject var mediaRemote = MediaRemoteHandler.shared
    
    var body: some View {
        if let data = mediaRemote.trackData {
            VStack(alignment: .leading) {
                Text("Now Playing")
                    .fontWeight(.bold)
                    .padding(.bottom, 0.5)
                
                HStack {
                    if let url = URL(string: data.albumArt ?? "") {
                        CachedAsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .frame(width: 30, height: 30)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(data.name)
                            .font(.subheadline)
                        Text("by \(data.artist)")
                            .font(.subheadline)
                    }
                }
            }
        } else {
            Text("Nothing is playing in Apple Music!")
                .multilineTextAlignment(.leading)
        }
    }
}
