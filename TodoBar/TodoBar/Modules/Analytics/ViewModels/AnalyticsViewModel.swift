///
/// AnalyticsViewModel.swift
/// TodoBar
///
/// Analytics ViewModel
///

import Foundation
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var dailyStats: [DailyStat] = []
    @Published var tagDistribution: [(tag: String, count: Int)] = []
    @Published var selectedRange: DateRange = .last7Days
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let analyticsService: AnalyticsProviding
    private let exportService: Exporting
    private var cancellables = Set<AnyCancellable>()
    
    init(
        analyticsService: AnalyticsProviding = AnalyticsService(),
        exportService: Exporting = ExportService()
    ) {
        self.analyticsService = analyticsService
        self.exportService = exportService
        
        setupObservers()
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        $selectedRange
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .todosDidChange)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        isLoading = true
        
        Publishers.Zip(
            analyticsService.fetchDailyStats(range: selectedRange),
            analyticsService.fetchTagDistribution()
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] stats, distribution in
                self?.dailyStats = stats
                self?.tagDistribution = distribution
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Export
    
    func exportCSV() -> URL? {
        do {
            return try exportService.exportCSV(stats: dailyStats)
        } catch {
            errorMessage = "导出 CSV 失败: \(error.localizedDescription)"
            return nil
        }
    }
    
    func exportPDF() -> URL? {
        do {
            return try exportService.exportPDF(stats: dailyStats, tagDistribution: tagDistribution)
        } catch {
            errorMessage = "导出 PDF 失败: \(error.localizedDescription)"
            return nil
        }
    }
}

