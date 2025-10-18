///
/// AppDelegate.swift
/// TodoBar
///
/// 应用委托，管理状态栏和 Popover
///

import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusBarController: StatusBarController?
    private var popoverCoordinator: PopoverCoordinator?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏 Dock 图标，仅显示状态栏
        NSApp.setActivationPolicy(.accessory)
        
        // 请求通知权限
        requestNotificationPermission()
        
        // 初始化状态栏
        setupStatusBar()
        
        // 初始化 Popover 协调器
        setupPopoverCoordinator()
        
        // 注册通知观察者
        registerNotificationObservers()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // 清理资源
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知权限请求失败: \(error.localizedDescription)")
            }
        }
        center.delegate = self
    }
    
    private func setupStatusBar() {
        statusBarController = StatusBarController()
    }
    
    private func setupPopoverCoordinator() {
        popoverCoordinator = PopoverCoordinator()
        statusBarController?.popoverCoordinator = popoverCoordinator
    }
    
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleQuitApp),
            name: .quitApp,
            object: nil
        )
    }
    
    @objc private func handleQuitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 前台显示通知
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 处理用户点击通知
        let userInfo = response.notification.request.content.userInfo
        
        if let todoId = userInfo["todoId"] as? String {
            // 发送通知，打开对应的待办事项
            NotificationCenter.default.post(
                name: .reminderFired,
                object: nil,
                userInfo: ["todoId": todoId]
            )
        }
        
        completionHandler()
    }
}

