///
/// DashboardViewModel.swift
/// TodoBar
///
/// Dashboard ViewModel
///

import Foundation
import Combine

struct DashboardStats {
    var totalCount: Int = 0
    var completedCount: Int = 0
    var remainingTime: TimeInterval = 0
    var pomodoroCount: Int = 0
    
    var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var remainingTimeFormatted: String {
        let hours = Int(remainingTime) / 3600
        let minutes = Int(remainingTime) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
}

class DashboardViewModel: ObservableObject {
    @Published var stats = DashboardStats()
    @Published var isLoading = false
    
    private let persistence: TodoPersisting
    private let analyticsService: AnalyticsProviding
    private var cancellables = Set<AnyCancellable>()
    
    init(
        persistence: TodoPersisting = PersistenceController.shared,
        analyticsService: AnalyticsProviding
    ) {
        self.persistence = persistence
        self.analyticsService = analyticsService
        
        setupObservers()
        loadStats()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: .todosDidChange)
            .sink { [weak self] _ in
                self?.loadStats()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadStats() {
        isLoading = true
        
        Publishers.Zip(
            persistence.fetchAll(),
            analyticsService.fetchDailyStats(range: .last7Days)
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            },
            receiveValue: { [weak self] todos, dailyStats in
                self?.updateStats(todos: todos, dailyStats: dailyStats)
            }
        )
        .store(in: &cancellables)
    }
    
    private func updateStats(todos: [TodoItem], dailyStats: [DailyStat]) {
        let total = todos.count
        let completed = todos.filter { $0.completed }.count
        
        // 估算剩余时间（每个未完成任务 30 分钟）
        let remainingTasks = total - completed
        let estimatedTime = Double(remainingTasks) * 30 * 60
        
        // 统计番茄钟数量
        let pomodoroCount = dailyStats.reduce(0) { $0 + $1.pomodoroCount }
        
        stats = DashboardStats(
            totalCount: total,
            completedCount: completed,
            remainingTime: estimatedTime,
            pomodoroCount: pomodoroCount
        )
    }
    
    // MARK: - Actions
    
    func completeAll() {
        do {
            try persistence.completeAll()
        } catch {
            print("批量完成失败: \(error)")
        }
    }
    
    func delayAll(days: Int) {
        do {
            try persistence.delayAll(days: days)
        } catch {
            print("批量延迟失败: \(error)")
        }
    }
}

