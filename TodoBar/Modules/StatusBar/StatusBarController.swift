///
/// StatusBarController.swift
/// TodoBar
///
/// 状态栏控制器，管理状态栏图标和交互
///

import Cocoa
import SwiftUI

class StatusBarController {
    private var statusItem: NSStatusItem?
    weak var popoverCoordinator: PopoverCoordinator?
    
    init() {
        setupStatusItem()
        setupMenu()
    }
    
    // MARK: - Setup
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // 设置图标
            button.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "TodoBar")
            button.image?.isTemplate = true
            
            // 设置点击事件
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // 新建待办
        let addTodoItem = NSMenuItem(
            title: "✚ 新建待办",
            action: #selector(addTodoClicked),
            keyEquivalent: "n"
        )
        addTodoItem.target = self
        menu.addItem(addTodoItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Dashboard
        let dashboardItem = NSMenuItem(
            title: "📊 Dashboard",
            action: #selector(dashboardClicked),
            keyEquivalent: "d"
        )
        dashboardItem.target = self
        menu.addItem(dashboardItem)
        
        // 分析
        let analyticsItem = NSMenuItem(
            title: "📈 数据分析",
            action: #selector(analyticsClicked),
            keyEquivalent: "a"
        )
        analyticsItem.target = self
        menu.addItem(analyticsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 设置
        let settingsItem = NSMenuItem(
            title: "⚙️ 设置",
            action: #selector(settingsClicked),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 退出
        let quitItem = NSMenuItem(
            title: "退出 TodoBar",
            action: #selector(quitClicked),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    // MARK: - Actions
    
    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        // 判断是左键还是右键
        if event.type == .rightMouseUp {
            // 右键显示菜单
            statusItem?.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height), in: sender)
        } else {
            // 左键显示 Popover
            togglePopover(sender)
        }
    }
    
    private func togglePopover(_ sender: NSStatusBarButton) {
        if let popover = popoverCoordinator?.popover {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            }
        }
    }
    
    @objc private func addTodoClicked() {
        NotificationCenter.default.post(name: .openAddTodo, object: nil)
    }
    
    @objc private func dashboardClicked() {
        NotificationCenter.default.post(name: .openDashboard, object: nil)
    }
    
    @objc private func analyticsClicked() {
        NotificationCenter.default.post(name: .openAnalytics, object: nil)
    }
    
    @objc private func settingsClicked() {
        NotificationCenter.default.post(name: .openSettings, object: nil)
    }
    
    @objc private func quitClicked() {
        NotificationCenter.default.post(name: .quitApp, object: nil)
    }
}

