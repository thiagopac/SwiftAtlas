import SwiftUI
import CoreData

struct CategoryListScreen: View {

    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.managedObjectContext) private var context
    @Environment(ContentSyncService.self) private var contentSync

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)])
    private var categories: FetchedResults<CategoryEntity>

    @State private var showSearch = false

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            if categories.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(categories) { category in
                            NavigationLink {
                                TopicListScreen(category: category)
                            } label: {
                                CategoryCellView(category: category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 20)
                }
            }
        }
        .fullScreenCover(isPresented: $showSearch) {
            SearchScreen()
                .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
        }
        .toolbar {
            GlobalToolbarContent(onSearch: { showSearch = true })

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

    private var background: Color {
        isDarkMode
            ? Color(red: 0.07, green: 0.07, blue: 0.09)
            : Color(UIColor.systemGroupedBackground)
    }

    @ViewBuilder
    private var emptyStateView: some View {
        switch contentSync.phase {
        case .failed(let message):
            VStack(spacing: 18) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text(message)
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button("Try Again") {
                    Task {
                        await contentSync.sync(context: context)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(28)
            .frame(maxWidth: 360)
        case .downloading(let progress):
            VStack(spacing: 18) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text("Downloading content")
                    .font(.system(.headline, design: .rounded))

                if let progress {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)

                    Text(progress.formatted(.percent.precision(.fractionLength(0))))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .padding(28)
            .frame(maxWidth: 360)
        case .importing:
            VStack(spacing: 18) {
                ProgressView()
                    .progressViewStyle(.circular)

                Text("Importing content")
                    .font(.system(.headline, design: .rounded))

                Text("Preparing the local catalog.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(28)
            .frame(maxWidth: 360)
        case .checking, .idle:
            VStack(spacing: 18) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text("Download catalog")
                    .font(.system(.headline, design: .rounded))

                Text("On the first launch, the app needs to fetch the content before it can build the local catalog.")
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button("Download Now") {
                    Task {
                        await contentSync.sync(context: context)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(28)
            .frame(maxWidth: 360)
        }
    }
}

struct CategoryCellView: View {

    let category: CategoryEntity

    @AppStorage("isDarkMode") private var isDarkMode = false

    private var accentColor: Color {
        category.slug.atlasAccentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(category.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)

                Spacer()
            }

            Spacer()

            Text(category.name)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(accentColor, lineWidth: 1.5)
        )
        .shadow(color: accentColor.opacity(isDarkMode ? 0.18 : 0.10), radius: 10, x: 0, y: 4)
    }

    private var cardBackground: some ShapeStyle {
        isDarkMode
            ? AnyShapeStyle(Color(red: 0.13, green: 0.13, blue: 0.16))
            : AnyShapeStyle(Color(UIColor.secondarySystemGroupedBackground))
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
            .environment(ContentSyncService.shared)
    }
}
