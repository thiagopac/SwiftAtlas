//
//  RemoteContent.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation

struct RemoteContent: Decodable {
    let version: Int
    let categories: [RemoteCategory]
}
