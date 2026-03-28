# Persistence Reference

Read ONLY the section matching the developer's chosen local storage approach.

---

## SwiftData (iOS 17+)

Apple's modern persistence framework. Simplest option for iOS 17+ apps.

### Model Definition

```swift
import SwiftData

@Model
final class [Name]Model {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var isActive: Bool

    // Relationships
    @Relationship(deleteRule: .cascade)
    var items: [ChildModel] = []

    init(id: UUID = UUID(), name: String, createdAt: Date = .now, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.isActive = isActive
    }
}
```

### App Configuration

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [[Name]Model.self, ChildModel.self])
    }
}
```

### Usage in Views

```swift
struct [Name]ListView: View {
    @Query(sort: \[Name]Model.createdAt, order: .reverse)
    private var items: [[Name]Model]

    @Environment(\.modelContext) private var context

    var body: some View {
        List(items) { item in
            Text(item.name)
        }
    }

    func addItem(name: String) {
        let item = [Name]Model(name: name)
        context.insert(item)
    }

    func deleteItem(_ item: [Name]Model) {
        context.delete(item)
    }
}
```

### Usage in Repository (with DI)

```swift
final class [Name]SwiftDataRepository: [Name]Repository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [[Name]] {
        let descriptor = FetchDescriptor<[Name]Model>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { [Name]Mapper.toDomain($0) }
    }

    func save(_ entity: [Name]) async throws -> Bool {
        let model = [Name]Mapper.toModel(entity)
        context.insert(model)
        try context.save()
        return true
    }
}
```

---

## Core Data

Apple's mature persistence framework. Works with iOS 15+.

### Setup
Core Data requires a `.xcdatamodeld` file created in Xcode. Define entities and attributes visually, then generate NSManagedObject subclasses.

### Persistence Controller

```swift
final class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Add sample data
        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AppModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error { fatalError("Core Data load error: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    func save() throws {
        let context = viewContext
        guard context.hasChanges else { return }
        try context.save()
    }
}
```

### Repository with Core Data

```swift
final class [Name]CoreDataRepository: [Name]Repository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func fetchAll() async throws -> [[Name]] {
        let request: NSFetchRequest<[Name]Entity> = [Name]Entity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \[Name]Entity.createdAt, ascending: false)]
        let entities = try context.fetch(request)
        return entities.compactMap([Name]CoreDataMapper.toDomain)
    }

    func save(_ item: [Name]) async throws -> Bool {
        let entity = [Name]Entity(context: context)
        [Name]CoreDataMapper.toEntity(item, entity: entity)
        try context.save()
        return true
    }

    func delete(_ id: UUID) async throws -> Bool {
        let request: NSFetchRequest<[Name]Entity> = [Name]Entity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try context.save()
            return true
        }
        return false
    }
}
```

---

## UserDefaults + Codable

Lightweight persistence using Codable encoding. Best for small datasets, settings, and cart-like data.

### Generic Local Storage

```swift
protocol LocalStorageProtocol {
    associatedtype Item: Codable & Identifiable where Item.ID == UUID
    func save(_ items: [Item]) throws
    func load() throws -> [Item]
    func find(_ id: UUID) throws -> Item?
    func delete(_ id: UUID) throws
    func clear()
}

final class LocalStorage<T: Codable & Identifiable>: LocalStorageProtocol where T.ID == UUID {
    typealias Item = T

    private let defaults: UserDefaults
    private let key: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(key: String, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    func save(_ items: [T]) throws {
        let data = try encoder.encode(items)
        defaults.set(data, forKey: key)
    }

    func load() throws -> [T] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return try decoder.decode([T].self, from: data)
    }

    func find(_ id: UUID) throws -> T? {
        try load().first { $0.id == id }
    }

    func delete(_ id: UUID) throws {
        var items = try load()
        items.removeAll { $0.id == id }
        try save(items)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
```

### Usage

```swift
let cartStorage = LocalStorage<CartItem>(key: "cart_items")

// Save
try cartStorage.save(cartItems)

// Load
let items = try cartStorage.load()

// In Repository
final class CartLocalRepository {
    private let storage = LocalStorage<CartItem>(key: "cart_items")

    func fetchCart() async throws -> [CartItem] {
        try storage.load()
    }

    func saveCart(_ items: [CartItem]) async throws {
        try storage.save(items)
    }
}
```

### Limitations
- Not suitable for large datasets (>1000 items)
- No query/filter capability (load all, filter in memory)
- No relationships between entities
- No migration support
- Best for: carts, favorites, user preferences, drafts

---

## Realm

Third-party database with rich query support and real-time sync.

### Setup

```swift
.package(url: "https://github.com/realm/realm-swift.git", from: "10.45.0")
```

### Model Definition

```swift
import RealmSwift

final class [Name]Object: Object, Identifiable {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var createdAt: Date
    @Persisted var isActive: Bool

    // Relationships
    @Persisted var items: List<ChildObject>

    convenience init(id: UUID = UUID(), name: String) {
        self.init()
        self.id = id
        self.name = name
        self.createdAt = .now
        self.isActive = true
    }
}
```

### Repository with Realm

```swift
import RealmSwift

final class [Name]RealmRepository: [Name]Repository {
    private let realm: Realm

    init(realm: Realm = try! Realm()) {
        self.realm = realm
    }

    func fetchAll() async throws -> [[Name]] {
        let objects = realm.objects([Name]Object.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
        return objects.map([Name]RealmMapper.toDomain)
    }

    func save(_ item: [Name]) async throws -> Bool {
        let object = [Name]RealmMapper.toObject(item)
        try realm.write {
            realm.add(object, update: .modified)
        }
        return true
    }

    func delete(_ id: UUID) async throws -> Bool {
        guard let object = realm.object(ofType: [Name]Object.self, forPrimaryKey: id) else {
            return false
        }
        try realm.write {
            realm.delete(object)
        }
        return true
    }
}
```

---

## Choosing Persistence

| Approach | Best For | iOS Version | Complexity |
|----------|---------|-------------|------------|
| **SwiftData** | New apps, simple to medium models | iOS 17+ | Low |
| **Core Data** | Complex models, backward compat | iOS 15+ | Medium-High |
| **UserDefaults** | Small data, settings, carts | Any | Low |
| **Realm** | Complex queries, offline sync | Any | Medium |
