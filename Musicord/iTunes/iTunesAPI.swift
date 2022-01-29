//
//  iTunesAPI.swift
//  Musicord
//
//  Created by Conor Byrne on 30/01/2022.
//

import Foundation

enum iTunesAPIError : Error {
    case invalidUrl, missingData, alreadyFetching
}

struct iTunesAPI {
    private init() {
    }
    
    private static var requestCache: [Int : iTunesLookupResult] = [:]
    private static var currentRequests: [Int] = []
    
    static func lookup(id: Int, completion: @escaping (Result<[iTunesLookupItem], Error>) -> Void) {
        do {
            if requestCache.count >= 20 {
                print("Clearing cache")
                requestCache.removeAll()
            }
            
            let url = try buildUrl("lookup", parameters: ["id": "\(id)"])
            if let cached = requestCache[id] {
                completion(.success(cached.results))
                return
            }
            
            if currentRequests.contains(id) {
                completion(.failure(iTunesAPIError.alreadyFetching))
                return
            } else {
                currentRequests.append(id)
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(iTunesAPIError.missingData))
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(iTunesLookupResult.self, from: data)
                    
                    requestCache[id] = decoded
                    if let index = currentRequests.firstIndex(of: id) {
                        currentRequests.remove(at: index)
                    }
                    completion(.success(decoded.results))
                } catch (let error) {
                    completion(.failure(error))
                }
            }.resume()
        } catch (let error) {
            completion(.failure(error))
        }
    }
    
    static func buildUrl(_ path: String, parameters: [String:String] = [:]) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "itunes.apple.com"
        components.path = "/\(path)"
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components.url else {
            throw iTunesAPIError.invalidUrl
        }

        return url
    }
}
