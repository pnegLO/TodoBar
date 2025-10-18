///
/// ExportService.swift
/// TodoBar
///
/// 数据导出服务
///

import Foundation
import AppKit

class ExportService: Exporting {
    
    // MARK: - CSV Export
    
    func exportCSV(stats: [DailyStat]) throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var csvString = "日期,总数,已完成,完成率,番茄钟\n"
        
        for stat in stats {
            let dateStr = dateFormatter.string(from: stat.date)
            let rate = String(format: "%.2f", stat.completionRate * 100)
            csvString += "\(dateStr),\(stat.totalCount),\(stat.completedCount),\(rate)%,\(stat.pomodoroCount)\n"
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "TodoBar_Stats_\(timestamp).csv"
        let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        try csvString.write(to: url, atomically: true, encoding: .utf8)
        
        return url
    }
    
    // MARK: - PDF Export
    
    func exportPDF(stats: [DailyStat], tagDistribution: [(tag: String, count: Int)]) throws -> URL {
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "TodoBar_Report_\(timestamp).pdf"
        let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        // 创建 PDF 上下文
        let pdfRect = CGRect(x: 0, y: 0, width: 612, height: 792) // A4 size
        guard let pdfContext = CGContext(url as CFURL, mediaBox: &pdfRect.mutable, nil) else {
            throw NSError(domain: "ExportService", code: 1, userInfo: [NSLocalizedDescriptionKey: "无法创建 PDF 上下文"])
        }
        
        pdfContext.beginPDFPage(nil)
        
        // 绘制标题
        let title = "TodoBar 数据报告" as NSString
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 24),
            .foregroundColor: NSColor.black
        ]
        title.draw(at: CGPoint(x: 50, y: 720), withAttributes: titleAttributes)
        
        // 绘制日期
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = "生成时间: \(dateFormatter.string(from: Date()))" as NSString
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.gray
        ]
        date.draw(at: CGPoint(x: 50, y: 690), withAttributes: dateAttributes)
        
        // 绘制统计数据
        var yPosition: CGFloat = 640
        
        let sectionTitle = "完成统计" as NSString
        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 18),
            .foregroundColor: NSColor.black
        ]
        sectionTitle.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
        yPosition -= 30
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.black
        ]
        
        for stat in stats.prefix(10) {
            let dateStr = dateFormatter.string(from: stat.date)
            let line = "\(dateStr)  总数: \(stat.totalCount)  已完成: \(stat.completedCount)  完成率: \(String(format: "%.0f", stat.completionRate * 100))%" as NSString
            line.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: textAttributes)
            yPosition -= 20
        }
        
        // 绘制标签分布
        yPosition -= 20
        let tagTitle = "标签分布" as NSString
        tagTitle.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
        yPosition -= 30
        
        let total = tagDistribution.reduce(0) { $0 + $1.count }
        for item in tagDistribution.prefix(10) {
            let percentage = Double(item.count) / Double(total) * 100
            let line = "#\(item.tag)  数量: \(item.count)  占比: \(String(format: "%.1f", percentage))%" as NSString
            line.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: textAttributes)
            yPosition -= 20
        }
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        return url
    }
}

// MARK: - CGRect Extension

extension CGRect {
    var mutable: CGRect {
        get { self }
        set { self = newValue }
    }
}

