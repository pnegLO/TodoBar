///
/// SettingsView.swift
/// TodoBar
///
/// 设置视图
///

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var persistence: PersistenceController
    @StateObject private var settingsService = SettingsService()
    @StateObject private var backupService = BackupService()
    
    @State private var showBackupSuccess = false
    @State private var showBackupError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: UIConstants.spacing) {
                // 通用设置
                GeneralSettingsSection(settings: settingsService)
                
                // 外观设置
                AppearanceSettingsSection(settings: settingsService)
                
                // 数据设置
                DataSettingsSection(
                    settings: settingsService,
                    backupService: backupService,
                    onBackupSuccess: { showBackupSuccess = true },
                    onBackupError: { error in
                        errorMessage = error
                        showBackupError = true
                    }
                )
                
                // 帮助 & 反馈
                HelpSection()
                
                // 重置按钮
                Button("恢复默认设置") {
                    settingsService.restoreDefaults()
                }
                .buttonStyle(.bordered)
            }
            .padding(UIConstants.spacing)
        }
        .alert("备份成功", isPresented: $showBackupSuccess) {
            Button("确定", role: .cancel) {}
        }
        .alert("备份失败", isPresented: $showBackupError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - General Settings Section

struct GeneralSettingsSection: View {
    @ObservedObject var settings: SettingsService
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("通用")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
                // 开机自启
                Toggle("开机自启", isOn: $settings.launchAtLogin)
                
                // 提醒方式
                HStack {
                    Text("默认提醒方式")
                    Spacer()
                    Picker("", selection: $settings.defaultReminderType) {
                        ForEach(ReminderType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                }
                
                // 番茄工作时长
                HStack {
                    Text("番茄工作时长")
                    Spacer()
                    Stepper("\(settings.pomodoroWorkDuration) 分钟", value: $settings.pomodoroWorkDuration, in: 1...60)
                }
                
                // 番茄休息时长
                HStack {
                    Text("番茄休息时长")
                    Spacer()
                    Stepper("\(settings.pomodoroBreakDuration) 分钟", value: $settings.pomodoroBreakDuration, in: 1...30)
                }
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
}

// MARK: - Appearance Settings Section

struct AppearanceSettingsSection: View {
    @ObservedObject var settings: SettingsService
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("外观")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
                // 主题模式
                HStack {
                    Text("主题模式")
                    Spacer()
                    Picker("", selection: $settings.themeMode) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                }
                
                // 状态栏图标大小
                HStack {
                    Text("状态栏图标大小")
                    Spacer()
                    Picker("", selection: $settings.statusBarIconSize) {
                        ForEach(IconSize.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                }
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
}

// MARK: - Data Settings Section

struct DataSettingsSection: View {
    @ObservedObject var settings: SettingsService
    @ObservedObject var backupService: BackupService
    let onBackupSuccess: () -> Void
    let onBackupError: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("数据")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
                // 自动清理
                Toggle("自动清理已完成任务", isOn: $settings.autoCleanupEnabled)
                
                if settings.autoCleanupEnabled {
                    HStack {
                        Text("清理时间")
                        Spacer()
                        Stepper("\(settings.autoCleanupDays) 天后删除", value: $settings.autoCleanupDays, in: 1...365)
                    }
                }
                
                Divider()
                
                // 备份导出
                Button(action: handleExportBackup) {
                    Label("导出备份", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                
                // 恢复备份
                Button(action: handleImportBackup) {
                    Label("恢复备份", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
    
    private func handleExportBackup() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.database]
        savePanel.nameFieldStringValue = "TodoBar_Backup_\(Int(Date().timeIntervalSince1970)).sqlite"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try backupService.exportCoreData(to: url)
                    onBackupSuccess()
                } catch {
                    onBackupError(error.localizedDescription)
                }
            }
        }
    }
    
    private func handleImportBackup() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.database]
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                do {
                    try backupService.importCoreData(from: url)
                    onBackupSuccess()
                } catch {
                    onBackupError(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Help Section

struct HelpSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("帮助 & 反馈")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
                Button(action: openUserGuide) {
                    Label("使用手册", systemImage: "book")
                }
                .buttonStyle(.borderless)
                
                Button(action: openFAQ) {
                    Label("常见问题", systemImage: "questionmark.circle")
                }
                .buttonStyle(.borderless)
                
                Button(action: sendFeedback) {
                    Label("发送反馈", systemImage: "envelope")
                }
                .buttonStyle(.borderless)
                
                Divider()
                
                HStack {
                    Text("版本")
                        .foregroundColor(.themeSecondaryText)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.themeSecondaryText)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
    
    private func openUserGuide() {
        // 打开用户手册 PDF
        if let url = Bundle.main.url(forResource: "UserGuide", withExtension: "pdf") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openFAQ() {
        // 打开常见问题网页
        if let url = URL(string: "https://todobar.app/faq") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func sendFeedback() {
        // 打开邮件客户端
        if let url = URL(string: "mailto:support@todobar.app?subject=TodoBar%20Feedback") {
            NSWorkspace.shared.open(url)
        }
    }
}

