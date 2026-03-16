//
//  CategoryListScreen.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import SwiftUI
import CoreData

struct CategoryListScreen: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)])
    private var categories: FetchedResults<CategoryEntity>
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
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
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: "swift")
                        .foregroundColor(.orange)

                    Text("Swift Atlas")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundColor(.primary)
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { } label: { Image(systemName: "moon") }
                Button { } label: { Image(systemName: "star") }
                Button { } label: { Image(systemName: "magnifyingglass") }
            }
        }
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
                    .frame(width: 55, height: 55)
                
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
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
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
