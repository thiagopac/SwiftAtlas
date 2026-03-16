//
//  RemoteSnippet.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation

struct RemoteSnippet: Decodable {
    let id: String
    let title: String
    let language: String
    let order: Int
    let code: String
}
