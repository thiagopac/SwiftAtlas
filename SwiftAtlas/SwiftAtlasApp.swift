import SwiftUI

@main
struct SwiftAtlasApp: App {

    let persistence = CoreDataStack.shared
    @State private var bookmarks = BookmarkService.shared
    @State private var contentSync = ContentSyncService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.viewContext)
                .environment(bookmarks)
                .environment(contentSync)
                .task {
                    guard contentSync.hasLocalContent(context: persistence.viewContext) else {
                        return
                    }

                    await contentSync.sync(context: persistence.viewContext)
                }
        }
    }
}
