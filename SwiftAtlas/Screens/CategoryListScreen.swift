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
        (isDarkMode ? Color(red: 0.03, green: 0.04, blue: 0.06) : Color(.systemGroupedBackground))
        .ignoresSafeArea()
    }
}

struct CategoryCellView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
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
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(borderColor, lineWidth: 1)
        )
    }
    
    private var cardBackgroundColor: Color {
        isDarkMode ? Color(red: 0.10, green: 0.11, blue: 0.14) : Color.white
    }
    
    private var borderColor: Color {
        isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.05)
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
