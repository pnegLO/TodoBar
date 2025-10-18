///
/// MockNotificationService.swift
/// TodoBar
///
/// Mock 通知服务
///

import Foundation
@testable import TodoBar

class MockNotificationService: ObservableObject, NotificationProtocol {
    var scheduledNotifications: [UUID: Date] = [:]
    var shouldFail = false
    
    func scheduleReminder(for item: TodoItem, at date: Date) async throws {
        if shouldFail {
            throw NSError(domain: "Mock", code: 1, userInfo: nil)
        }
        scheduledNotifications[item.id] = date
    }
    
    func cancelReminder(for item: TodoItem) async throws {
        if shouldFail {
            throw NSError(domain: "Mock", code: 1, userInfo: nil)
        }
        scheduledNotifications.removeValue(forKey: item.id)
    }
    
    func cancelAllReminders() async throws {
        if shouldFail {
            throw NSError(domain: "Mock", code: 1, userInfo: nil)
        }
        scheduledNotifications.removeAll()
    }
}

