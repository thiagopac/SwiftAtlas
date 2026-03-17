//
//  TopicListScreen.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import SwiftUI
import CoreData

struct TopicListScreen: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @FetchRequest private var topics: FetchedResults<TopicEntity>

    let category: CategoryEntity

    init(category: CategoryEntity) {

        self.category = category

        _topics = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \TopicEntity.order, ascending: true)
            ],
            predicate: NSPredicate(format: "category.id == %@", category.id)
        )
    }
    
    var body: some View {
        List(topics) { topic in
            NavigationLink {
                TopicDetailScreen(topic: topic)
            } label: {
                HStack {
                    Image(systemName: topic.icon)
                        .foregroundStyle(accentColor)

                    Text(topic.title)
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 6)
            }
            .listRowBackground(Color(.secondarySystemBackground))
        }
        .scrollContentBackground(.hidden)
        .background(listBackground)
        .navigationTitle(category.name)
        .toolbar {
            GlobalToolbarContent()
        }
    }
    
    private var accentColor: Color {
        category.slug.atlasAccentColor
    }
    
    private var listBackground: some View {
        LinearGradient(
            colors: isDarkMode
                ? [
                    accentColor.opacity(0.16),
                    Color(red: 0.07, green: 0.08, blue: 0.11),
                    Color.black
                ]
                : [
                    accentColor.opacity(0.10),
                    Color(.systemBackground),
                    Color(.systemGroupedBackground)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {

    let stack = CoreDataStack(inMemory: true)
    let context = stack.viewContext

    let category = CategoryEntity(context: context)
    category.id = "preview"
    category.name = "SwiftUI"
    category.slug = "swiftui"
    category.icon = "swiftui-icon"
    category.order = 1

    let topic = TopicEntity(context: context)
    topic.id = "text"
    topic.title = "Text"
    topic.slug = "text"
    topic.summary = "Displays read-only text"
    topic.icon = "textformat"
    topic.order = 1
    topic.platformAvailability = "iOS 13+"
    topic.category = category
    
    let vstack = TopicEntity(context: context)
    vstack.id = "vstack"
    vstack.title = "VStack"
    vstack.slug = "slug"
    vstack.summary = "A view that arranges its children in a vertical line"
    vstack.icon = "square.stack.3d.up"
    vstack.platformAvailability = "iOS 13+"
    vstack.category = category
    

    try? context.save()

    return NavigationStack {
        TopicListScreen(category: category)
    }
    .environment(\.managedObjectContext, context)
}
