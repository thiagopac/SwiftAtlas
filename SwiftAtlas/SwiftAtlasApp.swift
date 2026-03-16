//
//  SwiftAtlasApp.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 11/03/26.
//


import SwiftUI

@main
struct SwiftAtlasApp: App {

    let persistence = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            CategoryListScreen()
                .environment(\.managedObjectContext, persistence.viewContext)
                .task {
                    await ContentSyncService.sync(
                        context: persistence.viewContext
                    )
                }
        }
    }
}
