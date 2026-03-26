import SwiftUI

@main
struct SwiftAtlasApp: App {

    let persistence = CoreDataStack.shared
    @State private var bookmarks = BookmarkService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.viewContext)
                .environment(bookmarks)
                .task {
                    await ContentSyncService.sync(
                        context: persistence.viewContext
                    )
                }
        }
    }
}
