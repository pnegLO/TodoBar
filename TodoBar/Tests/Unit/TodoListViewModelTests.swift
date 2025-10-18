///
/// TodoListViewModelTests.swift
/// TodoBar
///
/// TodoListViewModel 单元测试
///

import XCTest
import Combine
@testable import TodoBar

final class TodoListViewModelTests: XCTestCase {
    var sut: TodoListViewModel!
    var mockPersistence: MockTodoPersisting!
    var mockNotification: MockNotificationService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockPersistence = MockTodoPersisting()
        mockNotification = MockNotificationService()
        sut = TodoListViewModel(
            persistence: mockPersistence,
            notificationService: mockNotification
        )
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        mockPersistence = nil
        mockNotification = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testLoadTodos() {
        // Given
        let testTodos = [
            TodoItem(title: "Test 1"),
            TodoItem(title: "Test 2")
        ]
        mockPersistence.todos = testTodos
        
        let expectation = XCTestExpectation(description: "Todos loaded")
        
        // When
        sut.$todos
            .dropFirst()
            .sink { todos in
                XCTAssertEqual(todos.count, 2)
                XCTAssertEqual(todos[0].title, "Test 1")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.loadTodos()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddTodo() {
        // Given
        let newTodo = TodoItem(title: "New Todo")
        
        // When
        sut.addTodo(newTodo)
        
        // Then
        XCTAssertEqual(mockPersistence.todos.count, 1)
        XCTAssertEqual(mockPersistence.todos[0].title, "New Todo")
    }
    
    func testToggleComplete() {
        // Given
        var todo = TodoItem(title: "Test", completed: false)
        mockPersistence.todos = [todo]
        
        // When
        sut.toggleComplete(todo)
        
        // Then
        XCTAssertTrue(mockPersistence.todos[0].completed)
    }
    
    func testStatistics() {
        // Given
        mockPersistence.todos = [
            TodoItem(title: "Todo 1", completed: false),
            TodoItem(title: "Todo 2", completed: true),
            TodoItem(title: "Todo 3", completed: true)
        ]
        sut.loadTodos()
        
        // Wait for async load
        let expectation = XCTestExpectation(description: "Stats calculated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Then
            XCTAssertEqual(self.sut.totalCount, 3)
            XCTAssertEqual(self.sut.completedCount, 2)
            XCTAssertEqual(self.sut.completionRate, 2.0/3.0, accuracy: 0.01)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

