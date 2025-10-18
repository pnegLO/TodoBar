///
/// TodoListViewModel.swift
/// TodoBar
///
/// Todo 列表 ViewModel
///

import Foundation
import Combine

class TodoListViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var searchKeyword: String = ""
    @Published var selectedTags: [String] = []
    @Published var filterCompleted: Bool? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let persistence: TodoPersisting
    private let notificationService: NotificationProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        persistence: TodoPersisting = PersistenceController.shared,
        notificationService: NotificationProtocol
    ) {
        self.persistence = persistence
        self.notificationService = notificationService
        
        setupObservers()
        loadTodos()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // 监听 CoreData 变化
        NotificationCenter.default.publisher(for: .todosDidChange)
            .sink { [weak self] _ in
                self?.loadTodos()
            }
            .store(in: &cancellables)
        
        // 监听搜索变化
        Publishers.CombineLatest3($searchKeyword, $selectedTags, $filterCompleted)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] keyword, tags, completed in
                self?.search(keyword: keyword, tags: tags, completed: completed)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadTodos() {
        isLoading = true
        
        persistence.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] items in
                    self?.todos = items
                }
            )
            .store(in: &cancellables)
    }
    
    func search(keyword: String, tags: [String], completed: Bool?) {
        guard !keyword.isEmpty || !tags.isEmpty || completed != nil else {
            loadTodos()
            return
        }
        
        isLoading = true
        
        persistence.search(keyword: keyword, tags: tags, completed: completed)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] items in
                    self?.todos = items
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - CRUD Operations
    
    func addTodo(_ item: TodoItem) {
        do {
            try persistence.add(item)
            
            // 如果有提醒，设置通知
            if let reminderDate = item.reminderDate {
                Task {
                    try? await notificationService.scheduleReminder(for: item, at: reminderDate)
                }
            }
        } catch {
            errorMessage = "添加失败: \(error.localizedDescription)"
        }
    }
    
    func updateTodo(_ item: TodoItem) {
        do {
            try persistence.update(item)
            
            // 更新通知
            Task {
                try? await notificationService.cancelReminder(for: item)
                if let reminderDate = item.reminderDate, !item.completed {
                    try? await notificationService.scheduleReminder(for: item, at: reminderDate)
                }
            }
        } catch {
            errorMessage = "更新失败: \(error.localizedDescription)"
        }
    }
    
    func deleteTodo(_ item: TodoItem) {
        do {
            try persistence.delete(item)
            
            // 取消通知
            Task {
                try? await notificationService.cancelReminder(for: item)
            }
        } catch {
            errorMessage = "删除失败: \(error.localizedDescription)"
        }
    }
    
    func toggleComplete(_ item: TodoItem) {
        var updatedItem = item
        updatedItem.completed.toggle()
        updatedItem.updatedAt = Date()
        updateTodo(updatedItem)
    }
    
    // MARK: - Batch Operations
    
    func completeAll() {
        do {
            try persistence.completeAll()
        } catch {
            errorMessage = "批量完成失败: \(error.localizedDescription)"
        }
    }
    
    func delayAll(days: Int) {
        do {
            try persistence.delayAll(days: days)
        } catch {
            errorMessage = "批量延迟失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Statistics
    
    var totalCount: Int {
        todos.count
    }
    
    var completedCount: Int {
        todos.filter { $0.completed }.count
    }
    
    var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var allTags: [String] {
        Array(Set(todos.flatMap { $0.tags })).sorted()
    }
}

