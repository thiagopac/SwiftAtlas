//
//  ContentSyncService.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import Foundation
import CoreData
import Observation

enum ContentSyncPhase: Equatable {
    case idle
    case checking
    case downloading(progress: Double?)
    case importing
    case failed(message: String)
}

@MainActor
@Observable
final class ContentSyncService {

    static let shared = ContentSyncService()

    var phase: ContentSyncPhase = .idle

    private init() {}

    var isSyncing: Bool {
        switch phase {
        case .checking, .downloading, .importing:
            return true
        case .idle, .failed:
            return false
        }
    }

    func hasLocalContent(context: NSManagedObjectContext) -> Bool {
        localCategoryCount(context: context) > 0
    }

    func sync(context: NSManagedObjectContext) async {
        let hasLocalContent = hasLocalContent(context: context)
        phase = hasLocalContent ? .idle : .checking

        let remote: RemoteContent

        do {
            remote = try await ContentAPI.fetchContent { [weak self] progress in
                guard let self else { return }
                self.phase = .downloading(progress: progress)
            }
        } catch {
            if hasLocalContent {
                phase = .idle
                print("Content sync skipped. Using cached content. Error:", error)
            } else {
                phase = .failed(message: "Could not load the catalog. Check your internet connection and try again.")
                print("Content sync failed:", error)
            }
            return
        }

        let localVersion = UserDefaults.standard.integer(forKey: "contentVersion")
        let needsImport = remote.version > localVersion || !hasLocalContent

        guard needsImport else {
            phase = .idle
            print("Content already up to date. Version:", localVersion)
            return
        }

        do {
            phase = .importing

            print("Wiping database...")
            try await ContentImporter.wipeDatabase(context: context)

            print("Updating content. Remote version:", remote.version, "Local version:", localVersion)

            try await ContentImporter.importContent(remote, context: context)
            UserDefaults.standard.set(remote.version, forKey: "contentVersion")

            phase = .idle
        } catch {
            phase = .failed(message: "Could not update the local catalog. Try again.")
            print("Content import failed:", error)
        }
    }

    private func localCategoryCount(context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")

        do {
            return try context.count(for: request)
        } catch {
            print("Failed to count local categories:", error)
            return 0
        }
    }
}
