///
/// NotificationService.swift
/// TodoBar
///
/// 本地通知服务
///

import Foundation
import UserNotifications

class NotificationService: ObservableObject, NotificationProtocol {
    
    func scheduleReminder(for item: TodoItem, at date: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = "待办提醒"
        content.body = item.title
        content.sound = .default
        content.userInfo = ["todoId": item.id.uuidString]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        try await UNUserNotificationCenter.current().add(request)
    }
    
    func cancelReminder(for item: TodoItem) async throws {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [item.id.uuidString]
        )
    }
    
    func cancelAllReminders() async throws {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

