///
/// SettingsService.swift
/// TodoBar
///
/// 设置服务
///

import Foundation
import ServiceManagement

class SettingsService: ObservableObject, SettingsProtocol {
    
    // MARK: - Published Properties
    
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "LaunchAtLogin")
            if launchAtLogin != oldValue {
                try? applyLaunchAtLogin()
            }
        }
    }
    
    @Published var defaultReminderType: ReminderType {
        didSet {
            if let data = try? JSONEncoder().encode(defaultReminderType) {
                UserDefaults.standard.set(data, forKey: "DefaultReminderType")
            }
        }
    }
    
    @Published var pomodoroWorkDuration: Int {
        didSet {
            UserDefaults.standard.set(pomodoroWorkDuration, forKey: "PomodoroWorkDuration")
        }
    }
    
    @Published var pomodoroBreakDuration: Int {
        didSet {
            UserDefaults.standard.set(pomodoroBreakDuration, forKey: "PomodoroBreakDuration")
        }
    }
    
    @Published var themeMode: ThemeMode {
        didSet {
            if let data = try? JSONEncoder().encode(themeMode) {
                UserDefaults.standard.set(data, forKey: "ThemeMode")
            }
            applyTheme()
        }
    }
    
    @Published var statusBarIconSize: IconSize {
        didSet {
            if let data = try? JSONEncoder().encode(statusBarIconSize) {
                UserDefaults.standard.set(data, forKey: "StatusBarIconSize")
            }
        }
    }
    
    @Published var autoCleanupDays: Int {
        didSet {
            UserDefaults.standard.set(autoCleanupDays, forKey: "AutoCleanupDays")
        }
    }
    
    @Published var autoCleanupEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoCleanupEnabled, forKey: "AutoCleanupEnabled")
        }
    }
    
    // MARK: - Initialization
    
    init() {
        // 加载保存的设置
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "LaunchAtLogin")
        
        if let data = UserDefaults.standard.data(forKey: "DefaultReminderType"),
           let reminderType = try? JSONDecoder().decode(ReminderType.self, from: data) {
            self.defaultReminderType = reminderType
        } else {
            self.defaultReminderType = .sound
        }
        
        self.pomodoroWorkDuration = UserDefaults.standard.integer(forKey: "PomodoroWorkDuration")
        if self.pomodoroWorkDuration == 0 { self.pomodoroWorkDuration = 25 }
        
        self.pomodoroBreakDuration = UserDefaults.standard.integer(forKey: "PomodoroBreakDuration")
        if self.pomodoroBreakDuration == 0 { self.pomodoroBreakDuration = 5 }
        
        if let data = UserDefaults.standard.data(forKey: "ThemeMode"),
           let theme = try? JSONDecoder().decode(ThemeMode.self, from: data) {
            self.themeMode = theme
        } else {
            self.themeMode = .system
        }
        
        if let data = UserDefaults.standard.data(forKey: "StatusBarIconSize"),
           let size = try? JSONDecoder().decode(IconSize.self, from: data) {
            self.statusBarIconSize = size
        } else {
            self.statusBarIconSize = .medium
        }
        
        self.autoCleanupDays = UserDefaults.standard.integer(forKey: "AutoCleanupDays")
        if self.autoCleanupDays == 0 { self.autoCleanupDays = 30 }
        
        self.autoCleanupEnabled = UserDefaults.standard.bool(forKey: "AutoCleanupEnabled")
    }
    
    // MARK: - Methods
    
    func applyLaunchAtLogin() throws {
        // 注意：macOS 13+ 需要使用新的 API
        // 这里使用简化实现
        if #available(macOS 13.0, *) {
            // 使用 SMAppService
            let service = SMAppService.mainApp
            if launchAtLogin {
                try service.register()
            } else {
                try service.unregister()
            }
        }
    }
    
    func restoreDefaults() {
        launchAtLogin = false
        defaultReminderType = .sound
        pomodoroWorkDuration = 25
        pomodoroBreakDuration = 5
        themeMode = .system
        statusBarIconSize = .medium
        autoCleanupDays = 30
        autoCleanupEnabled = false
    }
    
    private func applyTheme() {
        switch themeMode {
        case .system:
            NSApp.appearance = nil
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}

