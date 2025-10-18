///
/// TodoItemEntity+CoreData.swift
/// TodoBar
///
/// CoreData 实体定义
///

import CoreData

@objc(TodoItemEntity)
public class TodoItemEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var dueDate: Date?
    @NSManaged public var priority: Int16
    @NSManaged public var tags: [String]
    @NSManaged public var reminderDate: Date?
    @NSManaged public var completed: Bool
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}

extension TodoItemEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemEntity> {
        return NSFetchRequest<TodoItemEntity>(entityName: "TodoItemEntity")
    }
    
    func toModel() -> TodoItem {
        return TodoItem(
            id: id,
            title: title,
            dueDate: dueDate,
            priority: TodoItem.Priority(rawValue: priority) ?? .medium,
            tags: tags,
            reminderDate: reminderDate,
            completed: completed,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    func update(from model: TodoItem) {
        id = model.id
        title = model.title
        dueDate = model.dueDate
        priority = model.priority.rawValue
        tags = model.tags
        reminderDate = model.reminderDate
        completed = model.completed
        notes = model.notes
        createdAt = model.createdAt
        updatedAt = model.updatedAt
    }
}

