import SwiftUI
import CoreData
import UIKit
import Highlightr

struct TopicDetailScreen: View {

    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(BookmarkService.self) private var bookmarks

    var topic: TopicEntity

    @State private var iconVisible = false

    var sortedBlocks: [ContentBlockEntity] {
        let set = topic.blocks ?? []
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

                if !sortedBlocks.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(sortedBlocks) { block in
                            if block.type == "text" {
                                TextBlock(block: block)
                            } else if block.type == "snippet" {
                                CodeSnippetCard(block: block, accentColor: accentColor)
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
                                            in: .rect(cornerRadius: 18),
                                            shadowRadius: 4,
                                            shadowOpacity: 0.05
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    iconVisible = true
                }
            }
        }
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

                    if iconVisible {
                        Image(systemName: topic.icon)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.white)
                            .transition(.symbolEffect(.drawOn))
                    }
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

                Button {
                    bookmarks.toggle(topic)
                } label: {
                    Image(systemName: bookmarks.isFavorite(topic) ? "star.fill" : "star")
                        .font(.system(size: 22))
                        .foregroundStyle(bookmarks.isFavorite(topic) ? .yellow : .secondary)
                        .contentTransition(.symbolEffect(.replace.upUp))
                        .symbolEffect(.bounce, value: bookmarks.isFavorite(topic))
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.25, dampingFraction: 0.5), value: bookmarks.isFavorite(topic))
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

struct TextBlock: View {

    let block: ContentBlockEntity

    var body: some View {
        Text(block.textContent ?? "")
            .font(.body)
            .foregroundStyle(.primary)
            .lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CodeSnippetCard: View {

    let block: ContentBlockEntity
    let accentColor: Color

    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var didCopy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(block.title ?? "")
                        .font(.headline)
                        .foregroundStyle(isDarkMode ? .white : .primary)

                    Text((block.language ?? "swift").uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isDarkMode ? Color.white.opacity(0.65) : .secondary)
                }

                Spacer()

                Button {
                    UIPasteboard.general.string = block.code

                    withAnimation(.easeInOut(duration: 0.2)) {
                        didCopy = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            didCopy = false
                        }
                    }
                } label: {
                    Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(copyButtonForeground)
                }
                .buttonStyle(.plain)
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
            in: .rect(cornerRadius: 24),
            shadowRadius: 4,
            shadowOpacity: 0.05
        )
    }

    private var highlightedCode: AttributedString {
        let code = block.code ?? ""
        let lang = block.language ?? "swift"

        let fallback = NSAttributedString(
            string: code,
            attributes: [
                .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                .foregroundColor: isDarkMode ? UIColor(white: 0.92, alpha: 1) : UIColor.label
            ]
        )

        guard
            let highlighted = highlightr?.highlight(code, as: lang.lowercased()),
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

    private var copyButtonForeground: Color {
        isDarkMode ? .white.opacity(0.7) : accentColor
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

    let block1 = ContentBlockEntity(context: context)
    block1.id = "text-intro"
    block1.type = "text"
    block1.order = 1
    block1.textContent = "Text is the most fundamental view in SwiftUI. It renders a read-only string and can be customized with a large set of modifiers."
    block1.topic = topic

    let block2 = ContentBlockEntity(context: context)
    block2.id = "text-snippet-basic"
    block2.type = "snippet"
    block2.order = 2
    block2.title = "Basic Text"
    block2.code = "Text(\"Hello World\")"
    block2.language = "swift"
    block2.topic = topic

    let block3 = ContentBlockEntity(context: context)
    block3.id = "text-mid"
    block3.type = "text"
    block3.order = 3
    block3.textContent = "Modifiers are chained directly onto the view. Font, foreground style, and alignment are the most commonly used."
    block3.topic = topic

    let block4 = ContentBlockEntity(context: context)
    block4.id = "text-snippet-style"
    block4.type = "snippet"
    block4.order = 4
    block4.title = "Styled Text"
    block4.code = "Text(\"Hello World\")\n    .font(.title)\n    .foregroundStyle(.blue)"
    block4.language = "swift"
    block4.topic = topic

    let link = DocumentationLinkEntity(context: context)
    link.id = "text-doc"
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
