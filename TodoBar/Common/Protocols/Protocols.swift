///
/// Protocols.swift
/// TodoBar
///
/// 全局协议定义，实现依赖倒置
///

import Foundation
import Combine

// MARK: - Todo Persisting

/// TodoItem 持久化协议
protocol TodoPersisting: ObservableObject {
    /// 获取所有待办事项
    func fetchAll() -> AnyPublisher<[TodoItem], Error>
    
    /// 添加待办事项
    func add(_ item: TodoItem) throws
    
    /// 更新待办事项
    func update(_ item: TodoItem) throws
    
    /// 删除待办事项
    func delete(_ item: TodoItem) throws
    
    /// 批量完成
    func completeAll() throws
    
    /// 批量延迟
    func delayAll(days: Int) throws
    
    /// 搜索
    func search(keyword: String, tags: [String], completed: Bool?) -> AnyPublisher<[TodoItem], Error>
}

// MARK: - Notification Protocol

/// 本地通知协议
protocol NotificationProtocol: ObservableObject {
    /// 调度提醒
    func scheduleReminder(for item: TodoItem, at date: Date) async throws
    
    /// 取消提醒
    func cancelReminder(for item: TodoItem) async throws
    
    /// 取消所有提醒
    func cancelAllReminders() async throws
}

// MARK: - Analytics Providing

/// 数据分析提供协议
protocol AnalyticsProviding: ObservableObject {
    /// 获取每日统计数据
    func fetchDailyStats(range: DateRange) -> AnyPublisher<[DailyStat], Error>
    
    /// 获取标签分布
    func fetchTagDistribution() -> AnyPublisher<[(tag: String, count: Int)], Error>
    
    /// 记录完成事项
    func recordCompletion(for item: TodoItem) throws
    
    /// 记录番茄钟
    func recordPomodoro(date: Date) throws
}

// MARK: - Settings Protocol

/// 全局设置协议
protocol SettingsProtocol: ObservableObject {
    var launchAtLogin: Bool { get set }
    var defaultReminderType: ReminderType { get set }
    var pomodoroWorkDuration: Int { get set }
    var pomodoroBreakDuration: Int { get set }
    var themeMode: ThemeMode { get set }
    var statusBarIconSize: IconSize { get set }
    var autoCleanupDays: Int { get set }
    var autoCleanupEnabled: Bool { get set }
    
    /// 应用开机自启
    func applyLaunchAtLogin() throws
    
    /// 恢复默认设置
    func restoreDefaults()
}

// MARK: - Pomodoro Timing

/// 番茄钟计时协议
protocol PomodoroTiming: ObservableObject {
    var isRunning: Bool { get }
    var isWorkPhase: Bool { get }
    var remainingSeconds: Int { get }
    var currentTask: TodoItem? { get set }
    
    /// 开始计时
    func start()
    
    /// 暂停计时
    func pause()
    
    /// 重置计时
    func reset()
    
    /// 切换阶段
    func togglePhase()
    
    /// 跳过当前阶段
    func skip()
}

// MARK: - Exporting

/// 导出功能协议
protocol Exporting {
    /// 导出 CSV
    func exportCSV(stats: [DailyStat]) throws -> URL
    
    /// 导出 PDF
    func exportPDF(stats: [DailyStat], tagDistribution: [(tag: String, count: Int)]) throws -> URL
}

// MARK: - Backup Service Protocol

/// 备份服务协议
protocol BackupServiceProtocol {
    /// 导出 CoreData
    func exportCoreData(to url: URL) throws
    
    /// 导入 CoreData
    func importCoreData(from url: URL) throws
}

// MARK: - Launch At Login Managing

/// 开机自启管理协议
protocol LaunchAtLoginManaging {
    /// 应用设置
    func apply(enabled: Bool) throws
}

