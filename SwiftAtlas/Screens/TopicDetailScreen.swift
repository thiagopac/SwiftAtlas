//
//  TopicDetailScreen.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import SwiftUI
import CoreData

struct TopicDetailScreen: View {
    
    var topic: TopicEntity
    
    var sortedSnippets: [SnippetEntity] {
        let set = topic.snippets ?? []
        return set.sorted { $0.order < $1.order }
    }
    
    var sortedDocumentationLinks: [DocumentationLinkEntity] {
        let set = topic.documentationLinks ?? []
        return set.sorted { $0.order < $1.order }
    }

    
    var body: some View {
        ScrollView {

            VStack(alignment: .leading, spacing: 20) {

                Section() {
                    Text(topic.summary).padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    
                    Text(topic.platformAvailability).padding([.bottom], 10)
                }

                ForEach(sortedSnippets) { snippet in
                    VStack(alignment: .leading, spacing: 8) {

                        Text(snippet.title)
                            .font(.headline)

                        Text(snippet.code)
                            .font(.system(.body, design: .monospaced))
                    }
                }
                
                ForEach(sortedDocumentationLinks) { documentationLink in
                    VStack(alignment: .leading, spacing: 8) {

                        Text(documentationLink.title)
                            .font(.headline)

                        Text(documentationLink.url)
                    }
                }
                
            }
            .padding()
            
        }
        .navigationTitle(topic.title)
    }
}

#Preview {

    let stack = CoreDataStack(inMemory: true)
    let context = stack.viewContext

    let category = CategoryEntity(context: context)
    category.id = "swiftui"
    category.name = "SwiftUI"
    category.slug = "swiftui"
    category.icon = "swiftui-icon"
    category.order = 1

    let topic = TopicEntity(context: context)
    topic.id = "text"
    topic.title = "Text"
    topic.slug = "text"
    topic.icon = "textformat"
    topic.summary = "Displays read-only text."
    topic.platformAvailability = "iOS 13+"
    topic.order = 1
    topic.category = category

    try? context.save()

    return NavigationStack {
        TopicDetailScreen(topic: topic)
    }
    .environment(\.managedObjectContext, context)
}
