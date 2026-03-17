//
//  RootView.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 16/03/26.
//


import SwiftUI
import CoreData
import UIKit

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
            return Color(red: 1.00, green: 0.46, blue: 0.18)
        case "combine":
            return Color(
                uiColor: UIColor { traitCollection in
                    if traitCollection.userInterfaceStyle == .dark {
                        return UIColor(red: 0.92, green: 0.46, blue: 0.35, alpha: 1)
                    }

                    return UIColor(red: 0.79, green: 0.31, blue: 0.23, alpha: 1)
                }
            )
        case "uikit":
            return Color(
                uiColor: UIColor { traitCollection in
                    if traitCollection.userInterfaceStyle == .dark {
                        return UIColor(red: 0.63, green: 0.87, blue: 0.12, alpha: 1)
                    }

                    return UIColor(red: 0.48, green: 0.67, blue: 0.12, alpha: 1)
                }
            )
        default:
            return Color(red: 0.12, green: 0.76, blue: 0.93)
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
