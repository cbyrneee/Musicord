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
    
    private static var requestCache: [String : iTunesLookupResult] = [:]
    private static var currentRequests: [String] = []
    
    static func getCachedSearchResult(term: String) -> [iTunesLookupItem]? {
        return requestCache[term]?.results
    }
    
    static func search(term: String, completion: @escaping (Result<[iTunesLookupItem], Error>) -> Void) {
        do {
            if requestCache.count >= 20 {
                print("Clearing cache")
                requestCache.removeAll()
            }
            
            let url = try buildUrl("search", parameters: ["media": "music", "limit": "1", "term": term])
            if let cached = getCachedSearchResult(term: term) {
                completion(.success(cached))
                return
            }
            
            if currentRequests.contains(term) {
                completion(.failure(iTunesAPIError.alreadyFetching))
                return
            } else {
                currentRequests.append(term)
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
                    
                    requestCache[term] = decoded
                    if let index = currentRequests.firstIndex(of: term) {
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
