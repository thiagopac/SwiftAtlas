import Foundation
import CoreData

final class TopicSectionEntity: NSManagedObject, Identifiable {
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var slug: String
    @NSManaged var order: Int16
    @NSManaged var category: CategoryEntity
    @NSManaged var topics: Set<TopicEntity>?
}
