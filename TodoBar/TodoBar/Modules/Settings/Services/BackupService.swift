///
/// BackupService.swift
/// TodoBar
///
/// 备份服务
///

import Foundation
import CoreData

class BackupService: ObservableObject, BackupServiceProtocol {
    
    private let persistence = PersistenceController.shared
    
    func exportCoreData(to url: URL) throws {
        let coordinator = persistence.container.persistentStoreCoordinator
        
        guard let store = coordinator.persistentStores.first else {
            throw NSError(domain: "BackupService", code: 1, userInfo: [NSLocalizedDescriptionKey: "无法找到数据存储"])
        }
        
        guard let storeURL = store.url else {
            throw NSError(domain: "BackupService", code: 2, userInfo: [NSLocalizedDescriptionKey: "无法获取存储位置"])
        }
        
        // 复制数据库文件
        try FileManager.default.copyItem(at: storeURL, to: url)
        
        // 同时复制 WAL 和 SHM 文件（如果存在）
        let walURL = storeURL.appendingPathExtension("wal")
        let shmURL = storeURL.appendingPathExtension("shm")
        
        if FileManager.default.fileExists(atPath: walURL.path) {
            let destWAL = url.appendingPathExtension("wal")
            try? FileManager.default.copyItem(at: walURL, to: destWAL)
        }
        
        if FileManager.default.fileExists(atPath: shmURL.path) {
            let destSHM = url.appendingPathExtension("shm")
            try? FileManager.default.copyItem(at: shmURL, to: destSHM)
        }
    }
    
    func importCoreData(from url: URL) throws {
        let coordinator = persistence.container.persistentStoreCoordinator
        
        guard let store = coordinator.persistentStores.first else {
            throw NSError(domain: "BackupService", code: 1, userInfo: [NSLocalizedDescriptionKey: "无法找到数据存储"])
        }
        
        guard let storeURL = store.url else {
            throw NSError(domain: "BackupService", code: 2, userInfo: [NSLocalizedDescriptionKey: "无法获取存储位置"])
        }
        
        // 移除当前存储
        try coordinator.remove(store)
        
        // 删除旧文件
        try? FileManager.default.removeItem(at: storeURL)
        try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("wal"))
        try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("shm"))
        
        // 复制备份文件
        try FileManager.default.copyItem(at: url, to: storeURL)
        
        // 复制 WAL 和 SHM 文件（如果存在）
        let sourceWAL = url.appendingPathExtension("wal")
        let sourceSHM = url.appendingPathExtension("shm")
        
        if FileManager.default.fileExists(atPath: sourceWAL.path) {
            try? FileManager.default.copyItem(at: sourceWAL, to: storeURL.appendingPathExtension("wal"))
        }
        
        if FileManager.default.fileExists(atPath: sourceSHM.path) {
            try? FileManager.default.copyItem(at: sourceSHM, to: storeURL.appendingPathExtension("shm"))
        }
        
        // 重新添加存储
        try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: nil
        )
        
        // 通知数据变化
        NotificationCenter.default.post(name: .todosDidChange, object: nil)
    }
}

