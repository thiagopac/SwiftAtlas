//
//  CategoryListScreen.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import SwiftUI
import CoreData

struct CategoryListScreen: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)])
    private var categories: FetchedResults<CategoryEntity>
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                
                ForEach(categories) { category in
                    
                    NavigationLink {
                        TopicListScreen(category: category)
                    } label: {
                        CategoryCellView(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(backgroundGradient)
        .toolbar {
            GlobalToolbarContent()

            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: "swift")
                        .foregroundColor(.orange)

                    Text("Swift Atlas")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        ZStack {
            baseBackground

            RadialGradient(
                colors: [
                    Color(red: 0.09, green: 0.56, blue: 0.90).opacity(isDarkMode ? 0.55 : 0.35),
                    .clear
                ],
                center: .topLeading,
                startRadius: 40,
                endRadius: 420
            )

            RadialGradient(
                colors: [
                    Color(red: 1.00, green: 0.46, blue: 0.18).opacity(isDarkMode ? 0.50 : 0.30),
                    .clear
                ],
                center: .bottomLeading,
                startRadius: 60,
                endRadius: 420
            )

            RadialGradient(
                colors: [
                    Color(red: 0.79, green: 0.31, blue: 0.23).opacity(isDarkMode ? 0.40 : 0.24),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 50,
                endRadius: 360
            )

            RadialGradient(
                colors: [
                    Color(red: 0.48, green: 0.67, blue: 0.12).opacity(isDarkMode ? 0.42 : 0.24),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 50,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }

    private var baseBackground: some View {
        LinearGradient(
            colors: isDarkMode
                ? [
                    Color(red: 0.03, green: 0.04, blue: 0.08),
                    Color(red: 0.06, green: 0.05, blue: 0.10),
                    Color.black
                ]
                : [
                    Color(red: 0.95, green: 0.97, blue: 1.00),
                    Color(red: 0.98, green: 0.97, blue: 0.95),
                    Color(.systemGroupedBackground)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct CategoryCellView: View {

    let category: CategoryEntity
    
    var body: some View {
        VStack {
            
            HStack {
                Image(category.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Text(category.name)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .atlasGlassSurface(
            .surface,
            in: .rect(cornerRadius: 24)
        )
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

    return NavigationStack {
        CategoryListScreen()
            .environment(\.managedObjectContext, context)
    }
}
