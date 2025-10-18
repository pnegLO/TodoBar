///
/// DailyStat.swift
/// TodoBar
///
/// 每日统计数据模型
///

import Foundation

struct DailyStat: Identifiable, Codable {
    var id: UUID
    var date: Date // 只保留年月日
    var completedCount: Int
    var totalCount: Int
    var pomodoroCount: Int
    
    init(
        id: UUID = UUID(),
        date: Date,
        completedCount: Int = 0,
        totalCount: Int = 0,
        pomodoroCount: Int = 0
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.completedCount = completedCount
        self.totalCount = totalCount
        self.pomodoroCount = pomodoroCount
    }
    
    var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}

