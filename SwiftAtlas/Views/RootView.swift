//
//  RootView.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 16/03/26.
//


import SwiftUI
import CoreData
import UIKit

enum AtlasGlassLevel {
    case chrome
    case surface
    case element
}

struct RootView: View {

    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(BookmarkService.self) private var bookmarks

    var body: some View {
        @Bindable var bookmarks = bookmarks

        NavigationStack {
            CategoryListScreen()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $bookmarks.showFavorites) {
            FavoritesScreen()
                .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
                .environment(bookmarks)
        }
    }
}

struct GlobalToolbarContent: ToolbarContent {

    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(BookmarkService.self) private var bookmarks

    var onSearch: (() -> Void)? = nil

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                isDarkMode.toggle()
            } label: {
                Image(systemName: isDarkMode ? "sun.max" : "moon")
            }
            Button {
                bookmarks.showFavorites = true
            } label: {
                Image(systemName: "star")
            }
            Button {
                onSearch?()
            } label: {
                Image(systemName: "magnifyingglass")
            }
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
            return Color(
                uiColor: UIColor { traitCollection in
                    if traitCollection.userInterfaceStyle == .dark {
                        return UIColor(red: 0.15, green: 0.67, blue: 0.94, alpha: 1)
                    }

                    return UIColor(red: 0.09, green: 0.56, blue: 0.90, alpha: 1)
                }
            )
        }
    }
}

struct AtlasGlassSurfaceModifier<S: Shape>: ViewModifier {

    let level: AtlasGlassLevel
    let shape: S
    var shadowRadius: CGFloat = 18
    var shadowOpacity: Double = 0.16

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if reduceTransparency {
            content
                .contentShape(shape)
                .background {
                    shape.fill(Color(.secondarySystemBackground))
                }
                .overlay {
                    shape
                        .stroke(strokeColor, lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: shadowRadius / 3)
        } else {
            content
                .contentShape(shape)
                .glassEffect(glass, in: shape)
                .overlay {
                    shape
                        .stroke(strokeColor, lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: shadowRadius / 3)
        }
    }

    private var glass: Glass {
        switch level {
        case .chrome:
            return .regular.interactive()
        case .surface:
            return .regular
        case .element:
            return .regular.interactive()
        }
    }

    private var strokeColor: Color {
        switch level {
        case .chrome:
            return Color.white.opacity(0.34)
        case .surface:
            return Color.white.opacity(0.22)
        case .element:
            return Color.white.opacity(0.28)
        }
    }
}

extension View {

    func atlasGlassSurface<S: Shape>(
        _ level: AtlasGlassLevel = .surface,
        in shape: S,
        shadowRadius: CGFloat = 18,
        shadowOpacity: Double = 0.16
    ) -> some View {
        modifier(AtlasGlassSurfaceModifier(level: level, shape: shape, shadowRadius: shadowRadius, shadowOpacity: shadowOpacity))
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
        .environment(ContentSyncService.shared)
}
