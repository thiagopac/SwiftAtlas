import SwiftUI
import CoreData

struct SearchScreen: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var results: [TopicEntity] = []
    @FocusState private var isSearchFocused: Bool

    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                Divider()

                if searchText.isEmpty {
                    emptyPrompt
                } else if results.isEmpty {
                    noResults
                } else {
                    resultsList
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Text("Search")
                        .font(.headline)
                }
            }
            .onAppear {
                isSearchFocused = true
            }
            .onChange(of: searchText) {
                performSearch()
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Topics, snippets, text…", text: $searchText)
                .focused($isSearchFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var emptyPrompt: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.tertiary)
            Text("Search across topics, summaries,\nsnippets and text blocks")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }

    private var noResults: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "doc.questionmark")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.tertiary)
            Text("No results for \"\(searchText)\"")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
    }

    private var resultsList: some View {
        List(results) { topic in
            NavigationLink {
                TopicDetailScreen(topic: topic)
            } label: {
                SearchResultRow(topic: topic, query: searchText)
            }
            .listRowBackground(Color(UIColor.secondarySystemGroupedBackground))
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private func performSearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            return
        }

        let fetch = NSFetchRequest<TopicEntity>(entityName: "TopicEntity")
        fetch.predicate = NSPredicate(
            format: "title CONTAINS[cd] %@ OR summary CONTAINS[cd] %@ OR ANY blocks.textContent CONTAINS[cd] %@ OR ANY blocks.code CONTAINS[cd] %@ OR ANY blocks.title CONTAINS[cd] %@",
            trimmed, trimmed, trimmed, trimmed, trimmed
        )
        fetch.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        results = (try? context.fetch(fetch)) ?? []
    }
}

struct SearchResultRow: View {

    let topic: TopicEntity
    let query: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: topic.icon)
                    .font(.footnote)
                    .foregroundStyle(topic.category.slug.atlasAccentColor)

                Text(topic.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            Text(topic.category.name)
                .font(.caption)
                .foregroundStyle(topic.category.slug.atlasAccentColor)

            if let preview = matchPreview {
                Text(preview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }

    private var matchPreview: String? {
        let q = query.lowercased()

        if topic.summary.lowercased().contains(q) {
            return topic.summary
        }

        let sortedBlocks = (topic.blocks ?? []).sorted { $0.order < $1.order }

        for block in sortedBlocks {
            if let text = block.textContent, text.lowercased().contains(q) {
                return text
            }
            if let title = block.title, title.lowercased().contains(q) {
                return block.code
            }
            if let code = block.code, code.lowercased().contains(q) {
                return code
            }
        }

        return nil
    }
}
