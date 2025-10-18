///
/// DailyStatEntity+CoreData.swift
/// TodoBar
///
/// 每日统计 CoreData 实体
///

import CoreData

@objc(DailyStatEntity)
public class DailyStatEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var completedCount: Int32
    @NSManaged public var totalCount: Int32
    @NSManaged public var pomodoroCount: Int32
}

extension DailyStatEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyStatEntity> {
        return NSFetchRequest<DailyStatEntity>(entityName: "DailyStatEntity")
    }
    
    func toModel() -> DailyStat {
        return DailyStat(
            id: id,
            date: date,
            completedCount: Int(completedCount),
            totalCount: Int(totalCount),
            pomodoroCount: Int(pomodoroCount)
        )
    }
    
    func update(from model: DailyStat) {
        id = model.id
        date = model.date
        completedCount = Int32(model.completedCount)
        totalCount = Int32(model.totalCount)
        pomodoroCount = Int32(model.pomodoroCount)
    }
}

