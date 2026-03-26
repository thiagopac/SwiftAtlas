import Foundation
import Observation

@Observable
class BookmarkService {

    static let shared = BookmarkService()

    var showFavorites = false
    private(set) var favoriteIDs: Set<String>

    private let key = "favoriteTopicIDs"

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        favoriteIDs = Set(saved)
    }

    func toggle(_ topic: TopicEntity) {
        if favoriteIDs.contains(topic.id) {
            favoriteIDs.remove(topic.id)
        } else {
            favoriteIDs.insert(topic.id)
        }
        UserDefaults.standard.set(Array(favoriteIDs), forKey: key)
    }

    func isFavorite(_ topic: TopicEntity) -> Bool {
        favoriteIDs.contains(topic.id)
    }
}
