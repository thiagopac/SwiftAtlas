//
//  SnippetEntity.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation
import CoreData

final class SnippetEntity: NSManagedObject, Identifiable {
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var language: String
    @NSManaged var code: String
    @NSManaged var order: Int16
    @NSManaged var topic: TopicEntity
}
