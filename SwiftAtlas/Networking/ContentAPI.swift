//
//  ContentAPI.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation

enum NetworkError: Error {
    case invalidResponse
}

struct ContentAPI {
    
    static func fetchContent() async throws -> RemoteContent {
        
        let url = URL(string: "https://gist.githubusercontent.com/thiagopac/817fe7c50a209c3a41c9e455e70e6e90/raw/1a235bb60fa7d224f5f5c30995c09d9820a7c6b7/swift-atlas-data-v1.json")!
        
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              200...300 ~= http.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(RemoteContent.self, from: data)
    }
}
