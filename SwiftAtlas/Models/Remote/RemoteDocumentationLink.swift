//
//  RemoteDocumentationLink.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation

struct RemoteDocumentationLink: Decodable {
    let id: String
    let title: String
    let url: String
    let order: Int
}
