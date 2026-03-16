//
//  CoreDataStack.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation
import CoreData

final class CoreDataStack {

    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {

        container = NSPersistentContainer(name: "SwiftAtlasModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data failed: \(error)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
}
