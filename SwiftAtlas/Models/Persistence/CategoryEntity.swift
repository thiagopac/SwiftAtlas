//
//  CategoryEntity.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation
import CoreData

final class CategoryEntity: NSManagedObject, Identifiable {
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var icon: String
    @NSManaged var slug: String
    @NSManaged var order: Int16
    @NSManaged var topics: Set<TopicEntity>?
}
