import Foundation

struct RemoteContentBlock: Decodable {
    let id: String
    let type: String
    let order: Int
    let textContent: String?
    let code: String?
    let title: String?
    let language: String?
}
