///
/// PopoverCoordinator.swift
/// TodoBar
///
/// Popover 协调器，管理 Popover 的显示和 Tab 切换
///

import Cocoa
import SwiftUI

class PopoverCoordinator: ObservableObject {
    var popover: NSPopover?
    
    @Published var selectedTab: PopoverTab
    @Published var showAddTodoSheet = false
    
    init() {
        // 从 UserDefaults 恢复上次的 Tab
        let lastTabRawValue = UserDefaults.standard.string(forKey: "LastPopoverTab") ?? PopoverTab.todoList.rawValue
        selectedTab = PopoverTab(rawValue: lastTabRawValue) ?? .todoList
        
        setupPopover()
        registerNotificationObservers()
    }
    
    // MARK: - Setup
    
    private func setupPopover() {
        let popover = NSPopover()
        popover.contentSize = NSSize(
            width: UIConstants.popoverWidth,
            height: UIConstants.popoverHeight
        )
        popover.behavior = .transient
        popover.animates = true
        
        // 创建 SwiftUI 视图
        let contentView = PopoverView()
            .environmentObject(self)
            .environmentObject(PersistenceController.shared)
        
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        self.popover = popover
    }
    
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenAddTodo),
            name: .openAddTodo,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenDashboard),
            name: .openDashboard,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenAnalytics),
            name: .openAnalytics,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenSettings),
            name: .openSettings,
            object: nil
        )
    }
    
    // MARK: - Tab Selection
    
    func selectTab(_ tab: PopoverTab) {
        selectedTab = tab
        UserDefaults.standard.set(tab.rawValue, forKey: "LastPopoverTab")
    }
    
    // MARK: - Notification Handlers
    
    @objc private func handleOpenAddTodo() {
        selectTab(.todoList)
        showAddTodoSheet = true
        
        // 确保 Popover 是打开的
        if popover?.isShown == false {
            // 需要一个 sender，这里从状态栏获取
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Popover 会在左键点击时打开
            }
        }
    }
    
    @objc private func handleOpenDashboard() {
        selectTab(.dashboard)
    }
    
    @objc private func handleOpenAnalytics() {
        selectTab(.analytics)
    }
    
    @objc private func handleOpenSettings() {
        selectTab(.settings)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

