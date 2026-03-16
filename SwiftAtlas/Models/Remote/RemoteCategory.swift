//
//  RemoteCategory.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation

struct RemoteCategory: Decodable {
    let id: String
    let name: String
    let icon: String
    let slug: String
    let order: Int
    let topics: [RemoteTopic]
}
