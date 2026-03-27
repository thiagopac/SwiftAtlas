import Foundation

struct RemoteTopicSection: Decodable {
    let id: String
    let title: String
    let slug: String
    let order: Int
    let topics: [RemoteTopic]
}
