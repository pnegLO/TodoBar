///
/// TodoItem.swift
/// TodoBar
///
/// 待办事项数据模型
///

import Foundation

struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var dueDate: Date?
    var priority: Priority
    var tags: [String]
    var reminderDate: Date?
    var completed: Bool
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date? = nil,
        priority: Priority = .medium,
        tags: [String] = [],
        reminderDate: Date? = nil,
        completed: Bool = false,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.priority = priority
        self.tags = tags
        self.reminderDate = reminderDate
        self.completed = completed
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum Priority: Int16, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        
        var displayString: String {
            switch self {
            case .low: return "★"
            case .medium: return "★★"
            case .high: return "★★★"
            }
        }
    }
}

