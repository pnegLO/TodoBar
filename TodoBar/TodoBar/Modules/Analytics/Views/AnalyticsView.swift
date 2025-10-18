///
/// AnalyticsView.swift
/// TodoBar
///
/// Analytics 主视图
///

import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var showExportAlert = false
    @State private var exportedURL: URL?
    
    var body: some View {
        ScrollView {
            VStack(spacing: UIConstants.spacing) {
                // 日期范围选择
                DateRangePicker(selectedRange: $viewModel.selectedRange)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 任务完成趋势图
                    TrendLineChartView(stats: viewModel.dailyStats)
                    
                    // 标签占比图
                    TagDistributionChartView(distribution: viewModel.tagDistribution)
                    
                    // 导出按钮
                    ExportButtonsView(
                        onExportCSV: {
                            if let url = viewModel.exportCSV() {
                                exportedURL = url
                                showExportAlert = true
                            }
                        },
                        onExportPDF: {
                            if let url = viewModel.exportPDF() {
                                exportedURL = url
                                showExportAlert = true
                            }
                        }
                    )
                }
            }
            .padding(UIConstants.spacing)
        }
        .alert("导出成功", isPresented: $showExportAlert) {
            Button("打开文件夹") {
                if let url = exportedURL {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
            }
            Button("确定", role: .cancel) {}
        } message: {
            if let url = exportedURL {
                Text("文件已保存到：\n\(url.path)")
            }
        }
        .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("确定") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

// MARK: - Date Range Picker

struct DateRangePicker: View {
    @Binding var selectedRange: DateRange
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("日期范围")
                .font(.headline)
            
            HStack(spacing: UIConstants.smallSpacing) {
                Button("最近 7 天") {
                    selectedRange = .last7Days
                }
                .buttonStyle(rangeButtonStyle(.last7Days))
                
                Button("最近 30 天") {
                    selectedRange = .last30Days
                }
                .buttonStyle(rangeButtonStyle(.last30Days))
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
    
    private func rangeButtonStyle(_ range: DateRange) -> some PrimitiveButtonStyle {
        switch (selectedRange, range) {
        case (.last7Days, .last7Days), (.last30Days, .last30Days):
            return AnyButtonStyle(base: BorderedProminentButtonStyle())
        default:
            return AnyButtonStyle(base: BorderedButtonStyle())
        }
    }
}

// MARK: - Trend Line Chart View

struct TrendLineChartView: View {
    let stats: [DailyStat]
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("任务完成趋势")
                .font(.headline)
            
            if stats.isEmpty {
                Text("暂无数据")
                    .foregroundColor(.themeSecondaryText)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(stats) { stat in
                    LineMark(
                        x: .value("日期", stat.date, unit: .day),
                        y: .value("已完成", stat.completedCount)
                    )
                    .foregroundStyle(.green)
                    
                    LineMark(
                        x: .value("日期", stat.date, unit: .day),
                        y: .value("总数", stat.totalCount)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
}

// MARK: - Tag Distribution Chart View

struct TagDistributionChartView: View {
    let distribution: [(tag: String, count: Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("标签占比")
                .font(.headline)
            
            if distribution.isEmpty {
                Text("暂无数据")
                    .foregroundColor(.themeSecondaryText)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: UIConstants.smallSpacing) {
                    // 使用条形图替代饼图（macOS Charts 支持更好）
                    Chart(distribution.prefix(5), id: \.tag) { item in
                        BarMark(
                            x: .value("数量", item.count),
                            y: .value("标签", item.tag)
                        )
                        .foregroundStyle(by: .value("标签", item.tag))
                    }
                    .frame(height: 200)
                    
                    // 百分比列表
                    let total = distribution.reduce(0) { $0 + $1.count }
                    ForEach(distribution.prefix(5), id: \.tag) { item in
                        HStack {
                            Text(item.tag)
                                .font(.caption)
                            Spacer()
                            Text("\(item.count) (\(Int(Double(item.count) / Double(total) * 100))%)")
                                .font(.caption)
                                .foregroundColor(.themeSecondaryText)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
}

// MARK: - Export Buttons View

struct ExportButtonsView: View {
    let onExportCSV: () -> Void
    let onExportPDF: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("导出")
                .font(.headline)
            
            HStack(spacing: UIConstants.spacing) {
                Button(action: onExportCSV) {
                    Label("导出 CSV", systemImage: "doc.text")
                }
                .buttonStyle(.bordered)
                
                Button(action: onExportPDF) {
                    Label("导出 PDF", systemImage: "doc.richtext")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
    }
}

// MARK: - Any Button Style (Helper)

struct AnyButtonStyle: PrimitiveButtonStyle {
    private let _makeBody: (Configuration) -> AnyView
    
    init<S: PrimitiveButtonStyle>(base: S) {
        _makeBody = { configuration in
            AnyView(base.makeBody(configuration: configuration))
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

