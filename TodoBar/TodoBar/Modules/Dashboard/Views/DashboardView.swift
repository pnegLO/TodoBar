///
/// DashboardView.swift
/// TodoBar
///
/// Dashboard 主视图
///

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var persistence: PersistenceController
    @StateObject private var viewModel: DashboardViewModel
    @StateObject private var pomodoroService = PomodoroService()
    
    init() {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(
            persistence: PersistenceController.shared,
            analyticsService: AnalyticsService()
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: UIConstants.spacing) {
                // 番茄钟计时器
                PomodoroTimerView()
                    .environmentObject(pomodoroService)
                
                Divider()
                
                // 统计卡片
                StatisticsCardsView(stats: viewModel.stats)
                
                // 进度环形图
                CompletionChartView(stats: viewModel.stats)
                
                Divider()
                
                // 快速操作
                QuickActionsView(viewModel: viewModel)
            }
            .padding(UIConstants.spacing)
        }
    }
}

// MARK: - Statistics Cards View

struct StatisticsCardsView: View {
    let stats: DashboardStats
    
    var body: some View {
        VStack(spacing: UIConstants.smallSpacing) {
            HStack(spacing: UIConstants.smallSpacing) {
                StatCard(
                    title: "总数",
                    value: "\(stats.totalCount)",
                    icon: "list.bullet",
                    color: .themePrimary
                )
                
                StatCard(
                    title: "已完成",
                    value: "\(stats.completedCount)",
                    icon: "checkmark.circle.fill",
                    color: .themeSuccess
                )
            }
            
            HStack(spacing: UIConstants.smallSpacing) {
                StatCard(
                    title: "完成率",
                    value: String(format: "%.0f%%", stats.completionRate * 100),
                    icon: "chart.bar.fill",
                    color: .themeWarning
                )
                
                StatCard(
                    title: "番茄钟",
                    value: "\(stats.pomodoroCount)",
                    icon: "timer",
                    color: .themeError
                )
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: UIConstants.smallSpacing) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.themePrimaryText)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.themeSecondaryText)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
}

// MARK: - Completion Chart View

struct CompletionChartView: View {
    let stats: DashboardStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("完成进度")
                .font(.headline)
            
            ZStack {
                // 使用简单的圆环图
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: stats.completionRate)
                    .stroke(
                        Color.themeSuccess,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: stats.completionRate)
                
                VStack {
                    Text(String(format: "%.0f%%", stats.completionRate * 100))
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(stats.completedCount) / \(stats.totalCount)")
                        .font(.caption)
                        .foregroundColor(.themeSecondaryText)
                }
            }
            .frame(height: 150)
            .padding()
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
}

// MARK: - Quick Actions View

struct QuickActionsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var showConfirmComplete = false
    @State private var showDelayOptions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("快速操作")
                .font(.headline)
            
            HStack(spacing: UIConstants.smallSpacing) {
                Button("全部完成") {
                    showConfirmComplete = true
                }
                .buttonStyle(.borderedProminent)
                .confirmationDialog("确认", isPresented: $showConfirmComplete) {
                    Button("完成所有待办") {
                        viewModel.completeAll()
                    }
                    Button("取消", role: .cancel) {}
                } message: {
                    Text("确定要完成所有待办事项吗？")
                }
                
                Button("延迟 1 天") {
                    viewModel.delayAll(days: 1)
                }
                .buttonStyle(.bordered)
                
                Button("延迟 3 天") {
                    viewModel.delayAll(days: 3)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
}

