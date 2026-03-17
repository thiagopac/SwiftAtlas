//
//  RootView.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 16/03/26.
//


import SwiftUI
import CoreData

struct RootView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {

        NavigationStack {
            CategoryListScreen()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct GlobalToolbarContent: ToolbarContent {
    
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                isDarkMode.toggle()
            } label: {
                Image(systemName: isDarkMode ? "sun.max" : "moon")
            }
            Button { } label: { Image(systemName: "star") }
            Button { } label: { Image(systemName: "magnifyingglass") }
        }
    }
}

extension String {

    var atlasAccentColor: Color {
        switch self.lowercased() {
        case "swift":
            return .orange
        case "combine":
            return .red
        case "uikit":
            return .green
        default:
            return .blue
        }
    }
}

#Preview {
    
    let stack = CoreDataStack(inMemory: true)
    let context = stack.viewContext

    let swiftUICategory = CategoryEntity(context: context)
    swiftUICategory.id = "swiftui"
    swiftUICategory.name = "SwiftUI"
    swiftUICategory.slug = "swiftui"
    swiftUICategory.icon = "swiftui-icon"
    swiftUICategory.order = 1

    let swiftCategory = CategoryEntity(context: context)
    swiftCategory.id = "swift"
    swiftCategory.name = "Swift"
    swiftCategory.slug = "swift"
    swiftCategory.icon = "swift-icon"
    swiftCategory.order = 2

    let uiKitCategory = CategoryEntity(context: context)
    uiKitCategory.id = "uikit"
    uiKitCategory.name = "UIKit"
    uiKitCategory.slug = "uikit"
    uiKitCategory.icon = "uikit-icon"
    uiKitCategory.order = 3

    let combineCategory = CategoryEntity(context: context)
    combineCategory.id = "combine"
    combineCategory.name = "Combine"
    combineCategory.slug = "combine"
    combineCategory.icon = "pubsub-icon"
    combineCategory.order = 4

    try? context.save()
    
    return RootView()
        .environment(\.managedObjectContext, context)
}
