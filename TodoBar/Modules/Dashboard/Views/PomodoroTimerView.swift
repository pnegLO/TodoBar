///
/// PomodoroTimerView.swift
/// TodoBar
///
/// 番茄钟计时器视图
///

import SwiftUI

struct PomodoroTimerView: View {
    @EnvironmentObject var pomodoroService: PomodoroService
    
    var body: some View {
        VStack(spacing: UIConstants.spacing) {
            // 标题
            HStack {
                Image(systemName: "timer")
                    .font(.title2)
                Text(pomodoroService.isWorkPhase ? "工作阶段" : "休息阶段")
                    .font(.headline)
            }
            .foregroundColor(pomodoroService.isWorkPhase ? .themeError : .themeSuccess)
            
            // 倒计时显示
            Text(timeFormatted)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.themePrimaryText)
            
            // 进度条
            ProgressView(value: progress)
                .tint(pomodoroService.isWorkPhase ? .themeError : .themeSuccess)
            
            // 当前任务
            if let task = pomodoroService.currentTask {
                HStack {
                    Text("📄")
                    Text(task.title)
                        .lineLimit(1)
                    Text(task.priority.displayString)
                }
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)
            }
            
            // 控制按钮
            HStack(spacing: UIConstants.spacing) {
                if pomodoroService.isRunning {
                    Button(action: { pomodoroService.pause() }) {
                        Label("暂停", systemImage: "pause.fill")
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button(action: { pomodoroService.start() }) {
                        Label("开始", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button(action: { pomodoroService.skip() }) {
                    Label("跳过", systemImage: "forward.fill")
                }
                .buttonStyle(.bordered)
                
                Button(action: { pomodoroService.reset() }) {
                    Label("重置", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
    
    // MARK: - Computed Properties
    
    private var timeFormatted: String {
        let minutes = pomodoroService.remainingSeconds / 60
        let seconds = pomodoroService.remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var progress: Double {
        let total = pomodoroService.isWorkPhase
            ? pomodoroService.workDuration * 60
            : pomodoroService.breakDuration * 60
        let remaining = pomodoroService.remainingSeconds
        return 1.0 - (Double(remaining) / Double(total))
    }
}

