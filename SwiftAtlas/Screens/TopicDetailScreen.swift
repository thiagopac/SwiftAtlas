//
//  TopicDetailScreen.swift
//  SwiftAtlas
//
//  Created by Thiago Castro on 12/03/26.
//


import SwiftUI
import CoreData
import UIKit
import Highlightr

struct TopicDetailScreen: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
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
            VStack(alignment: .leading, spacing: 32) {
                GlassEffectContainer(spacing: 24) {
                    headerCard
                }
                summaryCard

                if !sortedSnippets.isEmpty {
                    GlassEffectContainer(spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Code Snippets", systemImage: "curlybraces.square")

                            ForEach(sortedSnippets) { snippet in
                                CodeSnippetCard(
                                    snippet: snippet,
                                    accentColor: accentColor
                                )
                            }
                        }
                    }
                }

                if !sortedDocumentationLinks.isEmpty {
                    GlassEffectContainer(spacing: 18) {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Documentation", systemImage: "book.pages")

                            ForEach(sortedDocumentationLinks) { documentationLink in
                                if let url = URL(string: documentationLink.url) {
                                    Link(destination: url) {
                                        HStack(alignment: .top, spacing: 10) {
                                            Image(systemName: "arrow.up.right.square")
                                                .foregroundStyle(accentColor)
                                                .padding(.top, 2)

                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(documentationLink.title)
                                                    .font(.headline)
                                                    .foregroundStyle(.primary)

                                                Text(documentationLink.url)
                                                    .font(.footnote)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(2)
                                            }

                                            Spacer(minLength: 0)
                                        }
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .atlasGlassSurface(
                                            .surface,
                                            in: .rect(cornerRadius: 18)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .background(detailBackground.ignoresSafeArea())
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            GlobalToolbarContent()
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(accentColor)

                    Image(systemName: topic.icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 6) {
                    Text(topic.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))

                    Text(topic.category.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                Label(topic.platformAvailability, systemImage: "iphone")
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(accentColor.opacity(0.12), in: Capsule())
                    .foregroundStyle(accentColor)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasGlassSurface(
            .surface,
            in: .rect(cornerRadius: 28)
        )
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Overview", systemImage: "text.alignleft")

            Text(topic.summary)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionTitle(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(accentColor)

            Text(title)
                .font(.system(.title3, design: .rounded, weight: .bold))
        }
    }
    
    private var accentColor: Color {
        topic.category.slug.atlasAccentColor
    }
    
    private var detailBackground: some View {
        LinearGradient(
            colors: isDarkMode
                ? [
                    Color(red: 0.04, green: 0.05, blue: 0.07),
                    accentColor.opacity(0.09),
                    Color(red: 0.08, green: 0.09, blue: 0.12)
                ]
                : [
                    Color(.systemBackground),
                    accentColor.opacity(0.05),
                    Color(.systemGroupedBackground)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct CodeSnippetCard: View {

    let snippet: SnippetEntity
    let accentColor: Color
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var didCopy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(snippet.title)
                        .font(.headline)
                        .foregroundStyle(isDarkMode ? .white : .primary)

                    Text(snippet.language.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isDarkMode ? Color.white.opacity(0.65) : .secondary)
                }

                Spacer()

                Button {
                    UIPasteboard.general.string = snippet.code

                    withAnimation(.easeInOut(duration: 0.2)) {
                        didCopy = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            didCopy = false
                        }
                    }
                } label: {
                    Label(didCopy ? "Copied" : "Copy", systemImage: didCopy ? "checkmark" : "doc.on.doc")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(copyButtonBackground, in: Capsule())
                }
                .buttonStyle(.plain)
                .foregroundStyle(copyButtonForeground)
            }

            Text(highlightedCode)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasGlassSurface(
            .surface,
            in: .rect(cornerRadius: 24)
        )
    }

    private var highlightedCode: AttributedString {
        let fallback = NSAttributedString(
            string: snippet.code,
            attributes: [
                .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                .foregroundColor: isDarkMode ? UIColor(white: 0.92, alpha: 1) : UIColor.label
            ]
        )

        guard
            let highlighted = highlightr?.highlight(snippet.code, as: snippet.language.lowercased()),
            let attributedString = try? AttributedString(highlighted, including: \.uiKit)
        else {
            return AttributedString(fallback)
        }

        return attributedString
    }
    
    private var highlightr: Highlightr? {
        let instance = Highlightr()
        instance?.setTheme(to: isDarkMode ? "atom-one-dark" : "atom-one-light")
        return instance
    }
    
    private var copyButtonBackground: Color {
        isDarkMode ? Color.white.opacity(0.12) : accentColor.opacity(0.12)
    }
    
    private var copyButtonForeground: Color {
        isDarkMode ? .white : accentColor
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
    topic.summary = "Displays one or more lines of read-only text. You can style it, combine modifiers and use it as the base for many SwiftUI interfaces."
    topic.platformAvailability = "iOS 13+"
    topic.order = 1
    topic.category = category

    let snippet = SnippetEntity(context: context)
    snippet.id = "snippet-text"
    snippet.title = "Basic usage"
    snippet.language = "swift"
    snippet.code = """
    struct ExampleView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Hello, SwiftUI")
                    .font(.title)
                    .foregroundStyle(.blue)

                Text("Readable and flexible UI code.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
    """
    snippet.order = 1
    snippet.topic = topic

    let link = DocumentationLinkEntity(context: context)
    link.id = "doc-text"
    link.title = "Apple Documentation"
    link.url = "https://developer.apple.com/documentation/swiftui/text"
    link.order = 1
    link.topic = topic

    try? context.save()

    return NavigationStack {
        TopicDetailScreen(topic: topic)
    }
    .environment(\.managedObjectContext, context)
}
