import Foundation
import CoreData

final class TopicEntity: NSManagedObject, Identifiable {
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var type: String
    @NSManaged var icon: String
    @NSManaged var slug: String
    @NSManaged var summary: String
    @NSManaged var order: Int16
    @NSManaged var platformAvailability: String
    @NSManaged var category: CategoryEntity
    @NSManaged var section: TopicSectionEntity?
    @NSManaged var blocks: Set<ContentBlockEntity>?
    @NSManaged var documentationLinks: Set<DocumentationLinkEntity>?
}
