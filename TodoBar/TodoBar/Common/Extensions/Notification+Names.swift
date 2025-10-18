///
/// Notification+Names.swift
/// TodoBar
///
/// 通知名称定义（事件总线）
///

import Foundation

extension Notification.Name {
    // MARK: - StatusBar Events
    
    static let showPopover = Notification.Name("ShowPopover")
    static let showMenu = Notification.Name("ShowMenu")
    
    // MARK: - Menu Commands
    
    static let openAddTodo = Notification.Name("OpenAddTodo")
    static let openDashboard = Notification.Name("OpenDashboard")
    static let openAnalytics = Notification.Name("OpenAnalytics")
    static let openSettings = Notification.Name("OpenSettings")
    static let quitApp = Notification.Name("QuitApp")
    
    // MARK: - Reminder Events
    
    static let reminderFired = Notification.Name("ReminderFired")
    
    // MARK: - Todo Events
    
    static let todosDidChange = Notification.Name("TodosDidChange")
}

