///
/// Enums.swift
/// TodoBar
///
/// 全局枚举定义
///

import Foundation

// MARK: - Popover Tab

enum PopoverTab: String, CaseIterable {
    case todoList = "Todo List"
    case dashboard = "Dashboard"
    case analytics = "Analytics"
    case settings = "Settings"
    
    var iconName: String {
        switch self {
        case .todoList: return "checklist"
        case .dashboard: return "chart.bar.fill"
        case .analytics: return "chart.line.uptrend.xyaxis"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Date Range

enum DateRange {
    case last7Days
    case last30Days
    case custom(start: Date, end: Date)
    
    var dates: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .last7Days:
            let start = calendar.date(byAdding: .day, value: -7, to: now)!
            return (start, now)
        case .last30Days:
            let start = calendar.date(byAdding: .day, value: -30, to: now)!
            return (start, now)
        case .custom(let start, let end):
            return (start, end)
        }
    }
}

// MARK: - Reminder Type

enum ReminderType: String, CaseIterable, Codable {
    case sound = "声音"
    case banner = "弹窗"
    case email = "邮件"
}

// MARK: - Theme Mode

enum ThemeMode: String, CaseIterable, Codable {
    case system = "系统"
    case light = "浅色"
    case dark = "深色"
}

// MARK: - Icon Size

enum IconSize: String, CaseIterable, Codable {
    case small = "小"
    case medium = "中"
    case large = "大"
    
    var points: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        }
    }
}

