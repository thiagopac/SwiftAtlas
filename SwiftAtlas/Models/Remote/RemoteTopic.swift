import Foundation

struct RemoteTopic: Decodable {
    let id: String
    let title: String
    let type: String
    let icon: String
    let summary: String
    let slug: String
    let platformAvailability: String
    let order: Int
    let blocks: [RemoteContentBlock]
    let documentationLinks: [RemoteDocumentationLink]
}
