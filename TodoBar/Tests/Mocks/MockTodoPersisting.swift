///
/// MockTodoPersisting.swift
/// TodoBar
///
/// Mock 实现用于测试
///

import Foundation
import Combine
@testable import TodoBar

class MockTodoPersisting: ObservableObject, TodoPersisting {
    var todos: [TodoItem] = []
    var shouldFail = false
    
    func fetchAll() -> AnyPublisher<[TodoItem], Error> {
        if shouldFail {
            return Fail(error: NSError(domain: "Mock", code: 1, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        return Just(todos)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func add(_ item: TodoItem) throws {
        if shouldFail {
            throw NSError(domain: "Mock", code: 1, userInfo: nil)
        }
        todos.append(item)
    }
    
    func update(_ item: TodoItem) throws {
        if shouldFail {
            throw NSError(domain: "Mock", code: 1, userInfo: nil)
        }
        
        if let index = todos.firstIndex(where: { $0.id == item.id }) {
            todos[index] = item
        }
    }
    
    func delete(_ item: TodoItem) throws {
        if shouldFail {
            throw NSError(domain: "Mock", code: 1, userInfo: nil)
        }
        
        todos.removeAll { $0.id == item.id }
    }
    
    func completeAll() throws {
        if shouldFail {
            throw NSError(domain: "Mock", code: 1, userInfo: nil)
        }
        
        for index in todos.indices {
            todos[index].completed = true
        }
    }
    
    func delayAll(days: Int) throws {
        if shouldFail {
            throw NSError(domain: "Mock", code: 1, userInfo: nil)
        }
        
        for index in todos.indices {
            if let dueDate = todos[index].dueDate {
                todos[index].dueDate = Calendar.current.date(byAdding: .day, value: days, to: dueDate)
            }
        }
    }
    
    func search(keyword: String, tags: [String], completed: Bool?) -> AnyPublisher<[TodoItem], Error> {
        var filtered = todos
        
        if !keyword.isEmpty {
            filtered = filtered.filter { $0.title.contains(keyword) }
        }
        
        if !tags.isEmpty {
            filtered = filtered.filter { item in
                tags.contains(where: { item.tags.contains($0) })
            }
        }
        
        if let completed = completed {
            filtered = filtered.filter { $0.completed == completed }
        }
        
        return Just(filtered)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

