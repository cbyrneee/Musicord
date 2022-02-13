//
//  UserView.swift
//  Musicord
//
//  Created by Conor Byrne on 29/01/2022.
//

import SwiftUI
import SwiftcordIPC
import CachedAsyncImage

struct UserView: View {
    @ObservedObject var discord = DiscordHandler.shared
    
    var body: some View {
        if let data = discord.connectionData {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .center, spacing: 10) {
                    CachedAsyncImage(url: avatarUrl(data: data)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())

                    HStack {
                        Text("Connected as **\(data.user.username)**#\(data.user.discriminator)")
                    }
                }
            }
            .padding()
            
            TrackView()
                .frame(maxWidth: .infinity)
                .padding(.bottom)
        } else {
            VStack {
                ProgressView()
                    .padding()
                
                Text("Attempting to connect to Discord...")
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func avatarUrl(data: ReadyData) -> URL? {
        return URL(string: "https://\(data.config.cdnHost)/avatars/\(data.user.id)/\(data.user.avatar).png?size=128")
    }
}
