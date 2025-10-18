///
/// PersistenceController.swift
/// TodoBar
///
/// CoreData 持久化控制器
///

import CoreData
import Combine

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "TodoBar")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("无法加载 CoreData: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func saveContext() throws {
        let context = container.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}

// MARK: - TodoPersisting Implementation

extension PersistenceController: TodoPersisting {
    
    func fetchAll() -> AnyPublisher<[TodoItem], Error> {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TodoItemEntity.completed, ascending: true),
            NSSortDescriptor(keyPath: \TodoItemEntity.dueDate, ascending: true),
            NSSortDescriptor(keyPath: \TodoItemEntity.priority, ascending: false)
        ]
        
        return Future<[TodoItem], Error> { promise in
            do {
                let entities = try self.viewContext.fetch(request)
                let items = entities.map { $0.toModel() }
                promise(.success(items))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func add(_ item: TodoItem) throws {
        let entity = TodoItemEntity(context: viewContext)
        entity.update(from: item)
        try saveContext()
        
        NotificationCenter.default.post(name: .todosDidChange, object: nil)
    }
    
    func update(_ item: TodoItem) throws {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        guard let entity = try viewContext.fetch(request).first else {
            throw NSError(domain: "TodoBar", code: 404, userInfo: [NSLocalizedDescriptionKey: "Todo item not found"])
        }
        
        entity.update(from: item)
        try saveContext()
        
        NotificationCenter.default.post(name: .todosDidChange, object: nil)
    }
    
    func delete(_ item: TodoItem) throws {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        guard let entity = try viewContext.fetch(request).first else {
            throw NSError(domain: "TodoBar", code: 404, userInfo: [NSLocalizedDescriptionKey: "Todo item not found"])
        }
        
        viewContext.delete(entity)
        try saveContext()
        
        NotificationCenter.default.post(name: .todosDidChange, object: nil)
    }
    
    func completeAll() throws {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "completed == NO")
        
        let entities = try viewContext.fetch(request)
        for entity in entities {
            entity.completed = true
            entity.updatedAt = Date()
        }
        
        try saveContext()
        NotificationCenter.default.post(name: .todosDidChange, object: nil)
    }
    
    func delayAll(days: Int) throws {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "completed == NO AND dueDate != nil")
        
        let entities = try viewContext.fetch(request)
        for entity in entities {
            if let dueDate = entity.dueDate {
                entity.dueDate = Calendar.current.date(byAdding: .day, value: days, to: dueDate)
                entity.updatedAt = Date()
            }
        }
        
        try saveContext()
        NotificationCenter.default.post(name: .todosDidChange, object: nil)
    }
    
    func search(keyword: String, tags: [String], completed: Bool?) -> AnyPublisher<[TodoItem], Error> {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        if !keyword.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", keyword))
        }
        
        if !tags.isEmpty {
            for tag in tags {
                predicates.append(NSPredicate(format: "ANY tags CONTAINS %@", tag))
            }
        }
        
        if let completed = completed {
            predicates.append(NSPredicate(format: "completed == %@", NSNumber(value: completed)))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TodoItemEntity.dueDate, ascending: true)
        ]
        
        return Future<[TodoItem], Error> { promise in
            do {
                let entities = try self.viewContext.fetch(request)
                let items = entities.map { $0.toModel() }
                promise(.success(items))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

