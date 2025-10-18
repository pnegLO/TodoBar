///
/// TodoBarApp.swift
/// TodoBar
///
/// 应用入口，负责全局单例注入和初始化
///

import SwiftUI

@main
struct TodoBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // 全局单例
    @StateObject private var persistenceController = PersistenceController.shared
    @StateObject private var settingsService = SettingsService()
    @StateObject private var notificationService = NotificationService()
    @StateObject private var pomodoroService = PomodoroService()
    
    var body: some Scene {
        // macOS 状态栏应用不需要 WindowGroup
        Settings {
            EmptyView()
        }
    }
}

