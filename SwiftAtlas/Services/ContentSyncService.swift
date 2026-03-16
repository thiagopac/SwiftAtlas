//
//  ContentSyncService.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation
import CoreData

struct ContentSyncService {

    static func sync(context: NSManagedObjectContext) async {

        do {

            let remote = try await ContentAPI.fetchContent()

            let localVersion = UserDefaults.standard.integer(forKey: "contentVersion")

            if remote.version > localVersion {
                
                print("Wiping database...")
                
                try await ContentImporter.wipeDatabase(context: context)

                print("Updating content. Remote version:", remote.version, "Local version:", localVersion)

                try await ContentImporter.importContent(remote, context: context)

                UserDefaults.standard.set(remote.version, forKey: "contentVersion")

            } else {

                print("Content already up to date. Version:", localVersion)

            }

        } catch {

            print("Content sync failed:", error)

        }
    }
}
