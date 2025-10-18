///
/// PomodoroService.swift
/// TodoBar
///
/// 番茄钟计时服务
///

import Foundation
import Combine

class PomodoroService: ObservableObject, PomodoroTiming {
    @Published var isRunning = false
    @Published var isWorkPhase = true
    @Published var remainingSeconds = 25 * 60
    @Published var currentTask: TodoItem?
    
    var workDuration: Int = 25 // 分钟
    var breakDuration: Int = 5 // 分钟
    
    private var timer: Timer?
    private let analyticsService: AnalyticsProviding
    
    init(analyticsService: AnalyticsProviding = AnalyticsService()) {
        self.analyticsService = analyticsService
        loadSettings()
    }
    
    // MARK: - Settings
    
    private func loadSettings() {
        workDuration = UserDefaults.standard.integer(forKey: "PomodoroWorkDuration")
        if workDuration == 0 { workDuration = 25 }
        
        breakDuration = UserDefaults.standard.integer(forKey: "PomodoroBreakDuration")
        if breakDuration == 0 { breakDuration = 5 }
        
        resetToCurrentPhase()
    }
    
    // MARK: - Timer Control
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        resetToCurrentPhase()
    }
    
    func togglePhase() {
        pause()
        isWorkPhase.toggle()
        resetToCurrentPhase()
    }
    
    func skip() {
        if isWorkPhase {
            // 工作阶段完成，记录统计
            recordWorkCompletion()
        }
        
        togglePhase()
    }
    
    // MARK: - Private Methods
    
    private func tick() {
        guard remainingSeconds > 0 else {
            onPhaseComplete()
            return
        }
        
        remainingSeconds -= 1
    }
    
    private func onPhaseComplete() {
        pause()
        
        if isWorkPhase {
            // 工作阶段完成
            recordWorkCompletion()
            playCompletionSound()
            showNotification(title: "工作阶段完成", body: "休息一下吧！")
        } else {
            // 休息阶段完成
            showNotification(title: "休息结束", body: "准备开始新的工作周期！")
        }
        
        togglePhase()
    }
    
    private func resetToCurrentPhase() {
        remainingSeconds = isWorkPhase ? (workDuration * 60) : (breakDuration * 60)
    }
    
    private func recordWorkCompletion() {
        do {
            try analyticsService.recordPomodoro(date: Date())
        } catch {
            print("记录番茄钟失败: \(error)")
        }
    }
    
    private func playCompletionSound() {
        // 播放系统提示音
        NSSound.beep()
    }
    
    private func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    deinit {
        timer?.invalidate()
    }
}

