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
    
    @FetchRequest private var sections: FetchedResults<TopicSectionEntity>
    @FetchRequest private var unsectionedTopics: FetchedResults<TopicEntity>

    let category: CategoryEntity

    init(category: CategoryEntity) {

        self.category = category

        _sections = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \TopicSectionEntity.order, ascending: true)
            ],
            predicate: NSPredicate(format: "category.id == %@", category.id)
        )

        _unsectionedTopics = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \TopicEntity.order, ascending: true)
            ],
            predicate: NSPredicate(format: "category.id == %@ AND section == nil", category.id)
        )
    }
    
    var body: some View {
        List {
            ForEach(sections) { section in
                Section(section.title) {
                    ForEach(sortedTopics(in: section)) { topic in
                        topicRow(topic)
                    }
                }
            }

            if !unsectionedTopics.isEmpty {
                Section(sections.isEmpty ? "" : "More") {
                    ForEach(unsectionedTopics) { topic in
                        topicRow(topic)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(listBackground)
        .toolbar {
            GlobalToolbarContent()

            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(category.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)

                    Text(category.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var accentColor: Color {
        category.slug.atlasAccentColor
    }
    
    private var listBackground: some View {
        LinearGradient(
            colors: isDarkMode
                ? [
                    Color(red: 0.04, green: 0.05, blue: 0.07),
                    accentColor.opacity(0.10),
                    Color(red: 0.08, green: 0.09, blue: 0.12)
                ]
                : [
                    Color(.systemGroupedBackground),
                    accentColor.opacity(0.06),
                    Color(.secondarySystemGroupedBackground)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var rowBackgroundColor: Color {
        isDarkMode ? Color(red: 0.09, green: 0.10, blue: 0.13) : Color.white
    }

    private func sortedTopics(in section: TopicSectionEntity) -> [TopicEntity] {
        let topics = section.topics ?? []
        return topics.sorted { $0.order < $1.order }
    }

    @ViewBuilder
    private func topicRow(_ topic: TopicEntity) -> some View {
        NavigationLink {
            TopicDetailScreen(topic: topic)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: topic.icon)
                    .frame(width: 20)
                    .foregroundStyle(accentColor)

                Text(topic.title)
                    .foregroundStyle(.primary)

                Spacer(minLength: 12)

                Text(topic.typeLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(accentColor.opacity(isDarkMode ? 0.18 : 0.10), in: Capsule())
            }
            .padding(.vertical, 6)
        }
        .listRowBackground(rowBackgroundColor)
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

    let basics = TopicSectionEntity(context: context)
    basics.id = "basics"
    basics.title = "Basics"
    basics.slug = "basics"
    basics.order = 1
    basics.category = category

    let topic = TopicEntity(context: context)
    topic.id = "text"
    topic.title = "Text"
    topic.type = "view"
    topic.slug = "text"
    topic.summary = "Displays read-only text"
    topic.icon = "textformat"
    topic.order = 1
    topic.platformAvailability = "iOS 13+"
    topic.category = category
    topic.section = basics
    
    let vstack = TopicEntity(context: context)
    vstack.id = "vstack"
    vstack.title = "VStack"
    vstack.type = "view"
    vstack.slug = "vstack"
    vstack.summary = "A view that arranges its children in a vertical line"
    vstack.icon = "square.stack.3d.up"
    vstack.order = 2
    vstack.platformAvailability = "iOS 13+"
    vstack.category = category
    vstack.section = basics
    

    try? context.save()

    return NavigationStack {
        TopicListScreen(category: category)
    }
    .environment(\.managedObjectContext, context)
}

private extension TopicEntity {
    var typeLabel: String {
        switch type {
        case "propertyWrapper":
            return "@Wrapper"
        case "environmentValue":
            return "Env Value"
        case "languageFeature":
            return "Language"
        case "opaqueType":
            return "Opaque Type"
        default:
            return type.prefix(1).uppercased() + type.dropFirst()
        }
    }
}
