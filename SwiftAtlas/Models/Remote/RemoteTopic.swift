//
//  RemoteTopic.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation

struct RemoteTopic: Decodable {

    let id: String
    let title: String
    let icon: String
    let summary: String
    let slug: String
    let platformAvailability: String
    let order: Int

    let snippets: [RemoteSnippet]
    let documentationLinks: [RemoteDocumentationLink]
}
