///
/// AnalyticsService.swift
/// TodoBar
///
/// 数据分析服务
///

import Foundation
import CoreData
import Combine

class AnalyticsService: ObservableObject, AnalyticsProviding {
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.viewContext = viewContext
    }
    
    // MARK: - Analytics Providing
    
    func fetchDailyStats(range: DateRange) -> AnyPublisher<[DailyStat], Error> {
        let dates = range.dates
        
        let request: NSFetchRequest<DailyStatEntity> = DailyStatEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            dates.start as CVarArg,
            dates.end as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyStatEntity.date, ascending: true)]
        
        return Future<[DailyStat], Error> { promise in
            do {
                let entities = try self.viewContext.fetch(request)
                let stats = entities.map { $0.toModel() }
                
                // 填充缺失的日期
                let filledStats = self.fillMissingDates(stats: stats, range: range)
                promise(.success(filledStats))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchTagDistribution() -> AnyPublisher<[(tag: String, count: Int)], Error> {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        
        return Future<[(tag: String, count: Int)], Error> { promise in
            do {
                let entities = try self.viewContext.fetch(request)
                
                var tagCounts: [String: Int] = [:]
                for entity in entities {
                    for tag in entity.tags {
                        tagCounts[tag, default: 0] += 1
                    }
                }
                
                let distribution = tagCounts.map { ($0.key, $0.value) }
                    .sorted { $0.1 > $1.1 }
                
                promise(.success(distribution))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func recordCompletion(for item: TodoItem) throws {
        let today = Calendar.current.startOfDay(for: Date())
        
        let request: NSFetchRequest<DailyStatEntity> = DailyStatEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", today as CVarArg)
        
        let entity: DailyStatEntity
        if let existing = try viewContext.fetch(request).first {
            entity = existing
        } else {
            entity = DailyStatEntity(context: viewContext)
            entity.id = UUID()
            entity.date = today
        }
        
        entity.completedCount += 1
        
        try viewContext.save()
    }
    
    func recordPomodoro(date: Date) throws {
        let today = Calendar.current.startOfDay(for: date)
        
        let request: NSFetchRequest<DailyStatEntity> = DailyStatEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", today as CVarArg)
        
        let entity: DailyStatEntity
        if let existing = try viewContext.fetch(request).first {
            entity = existing
        } else {
            entity = DailyStatEntity(context: viewContext)
            entity.id = UUID()
            entity.date = today
        }
        
        entity.pomodoroCount += 1
        
        try viewContext.save()
    }
    
    // MARK: - Helper Methods
    
    private func fillMissingDates(stats: [DailyStat], range: DateRange) -> [DailyStat] {
        let dates = range.dates
        let calendar = Calendar.current
        
        var result: [DailyStat] = []
        var currentDate = dates.start
        
        while currentDate <= dates.end {
            let dayStart = calendar.startOfDay(for: currentDate)
            
            if let stat = stats.first(where: { calendar.isDate($0.date, inSameDayAs: dayStart) }) {
                result.append(stat)
            } else {
                result.append(DailyStat(date: dayStart))
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return result
    }
}

