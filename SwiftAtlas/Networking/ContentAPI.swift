//
//  ContentAPI.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation

enum ContentError: Error {
    case fileNotFound
}

struct ContentAPI {

    static func fetchContent() async throws -> RemoteContent {
        guard let url = Bundle.main.url(forResource: "content", withExtension: "json") else {
            throw ContentError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(RemoteContent.self, from: data)
    }
}
