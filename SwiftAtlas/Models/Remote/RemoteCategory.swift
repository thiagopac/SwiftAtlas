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
    let sections: [RemoteTopicSection]
    let topics: [RemoteTopic]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case slug
        case order
        case sections
        case topics
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        slug = try container.decode(String.self, forKey: .slug)
        order = try container.decode(Int.self, forKey: .order)
        sections = try container.decodeIfPresent([RemoteTopicSection].self, forKey: .sections) ?? []
        topics = try container.decodeIfPresent([RemoteTopic].self, forKey: .topics) ?? []
    }
}
