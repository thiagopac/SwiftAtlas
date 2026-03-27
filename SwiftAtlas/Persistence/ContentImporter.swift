import Foundation
import CoreData

struct ContentImporter {

    static func wipeDatabase(context: NSManagedObjectContext) async throws {
        let entities = [
            "ContentBlockEntity",
            "DocumentationLinkEntity",
            "TopicEntity",
            "TopicSectionEntity",
            "CategoryEntity"
        ]

        for entity in entities {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let delete = NSBatchDeleteRequest(fetchRequest: fetch)
            try context.execute(delete)
        }
    }

    static func importContent(_ content: RemoteContent, context: NSManagedObjectContext) async throws {
        for remoteCategory in content.categories {
            let category = CategoryEntity(context: context)
            category.id = remoteCategory.id
            category.name = remoteCategory.name
            category.icon = remoteCategory.icon
            category.slug = remoteCategory.slug
            category.order = Int16(remoteCategory.order)

            for remoteSection in remoteCategory.sections {
                let section = TopicSectionEntity(context: context)
                section.id = remoteSection.id
                section.title = remoteSection.title
                section.slug = remoteSection.slug
                section.order = Int16(remoteSection.order)
                section.category = category

                for remoteTopic in remoteSection.topics {
                    importTopic(
                        remoteTopic,
                        context: context,
                        category: category,
                        section: section
                    )
                }
            }

            for remoteTopic in remoteCategory.topics {
                importTopic(
                    remoteTopic,
                    context: context,
                    category: category,
                    section: nil
                )
            }
        }

        try context.save()
    }

    private static func importTopic(
        _ remoteTopic: RemoteTopic,
        context: NSManagedObjectContext,
        category: CategoryEntity,
        section: TopicSectionEntity?
    ) {
        let topic = TopicEntity(context: context)
        topic.id = remoteTopic.id
        topic.title = remoteTopic.title
        topic.type = remoteTopic.type
        topic.icon = remoteTopic.icon
        topic.slug = remoteTopic.slug
        topic.summary = remoteTopic.summary
        topic.platformAvailability = remoteTopic.platformAvailability
        topic.order = Int16(remoteTopic.order)
        topic.category = category
        topic.section = section

        for remoteBlock in remoteTopic.blocks {
            let block = ContentBlockEntity(context: context)
            block.id = remoteBlock.id
            block.type = remoteBlock.type
            block.order = Int16(remoteBlock.order)
            block.textContent = remoteBlock.textContent
            block.code = remoteBlock.code
            block.title = remoteBlock.title
            block.language = remoteBlock.language
            block.topic = topic
        }

        for remoteDoc in remoteTopic.documentationLinks {
            let doc = DocumentationLinkEntity(context: context)
            doc.id = remoteDoc.id
            doc.title = remoteDoc.title
            doc.url = remoteDoc.url
            doc.order = Int16(remoteDoc.order)
            doc.topic = topic
        }
    }
}
