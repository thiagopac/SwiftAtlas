import SwiftUI
import CoreData

struct FavoritesScreen: View {

    @Environment(BookmarkService.self) private var bookmarks
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @AppStorage("isDarkMode") private var isDarkMode = false

    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \TopicEntity.order, ascending: true)
    ])
    private var allTopics: FetchedResults<TopicEntity>

    private var favoriteTopics: [TopicEntity] {
        allTopics.filter { bookmarks.isFavorite($0) }
    }

    private var groupedByCategory: [(category: String, slug: String, topics: [TopicEntity])] {
        var dict: [String: (slug: String, topics: [TopicEntity])] = [:]

        for topic in favoriteTopics {
            let name = topic.category.name
            let slug = topic.category.slug
            if dict[name] == nil {
                dict[name] = (slug: slug, topics: [])
            }
            dict[name]?.topics.append(topic)
        }

        return dict
            .map { (category: $0.key, slug: $0.value.slug, topics: $0.value.topics) }
            .sorted { $0.category < $1.category }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                if favoriteTopics.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("Favorites")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var list: some View {
        List {
            ForEach(groupedByCategory, id: \.category) { group in
                Section {
                    ForEach(group.topics) { topic in
                        NavigationLink {
                            TopicDetailScreen(topic: topic)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: topic.icon)
                                    .font(.body)
                                    .foregroundStyle(group.slug.atlasAccentColor)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(topic.title)
                                        .font(.body.weight(.medium))

                                    Text(topic.summary)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color(UIColor.secondarySystemGroupedBackground))
                    }
                } header: {
                    Text(group.category)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(group.slug.atlasAccentColor)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Image(systemName: "star")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.tertiary)
            Text("No favorites yet")
                .font(.title3.weight(.semibold))
            Text("Tap the star on any topic to save it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 60)
    }
}
