import Foundation
import CoreData

final class ContentBlockEntity: NSManagedObject, Identifiable {
    @NSManaged var id: String
    @NSManaged var type: String
    @NSManaged var order: Int16
    @NSManaged var textContent: String?
    @NSManaged var code: String?
    @NSManaged var title: String?
    @NSManaged var language: String?
    @NSManaged var topic: TopicEntity
}
