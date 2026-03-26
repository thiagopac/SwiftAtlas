import SwiftUI
import CoreData

struct CategoryListScreen: View {

    @AppStorage("isDarkMode") private var isDarkMode = false

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
    }
}
