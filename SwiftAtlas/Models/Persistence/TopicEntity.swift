//
//  TopicEntity.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation
import CoreData

final class TopicEntity: NSManagedObject, Identifiable {
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var icon: String
    @NSManaged var slug: String
    @NSManaged var summary: String
    @NSManaged var order: Int16
    @NSManaged var platformAvailability: String
    @NSManaged var category: CategoryEntity
    @NSManaged var documentationLinks: Set<DocumentationLinkEntity>?
    @NSManaged var snippets: Set<SnippetEntity>?
}
