//
//  CalibreDB.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB
import SwiftUI

class CalibreDB {
    var settingStore: SettingStore
    private var dbQueue: DatabaseQueue
    private var calibrePath: URL
    
    init(settingStore: SettingStore) throws {
        self.settingStore = settingStore
        
        guard let calibrePath = try settingStore.getCalibreURL() as URL? else {
            throw ErrorsToThrow.calibrePathNotResolving
        }
        self.calibrePath = calibrePath
        let databaseURL = calibrePath.appendingPathComponent("metadata.db")

        self.dbQueue = try! CalibreDB.openDatabase(atPath: databaseURL.path)
    }
    
    /// Creates a fully initialized database at path
    static func openDatabase(atPath path: String) throws -> DatabaseQueue {
        // Connect to the database
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
        let dbQueue = try DatabaseQueue(path: path)
        
        // Define the database schema
        //try migrator.migrate(dbQueue)

        return dbQueue
    }
    
    func load() throws  -> DatabaseQueue {
        
        guard let calibrePath = try settingStore.getCalibreURL() as URL? else {
            throw ErrorsToThrow.calibrePathNotResolving
        }
        let databaseURL = calibrePath.appendingPathComponent("metadata.db")

        let dbQueue = try! CalibreDB.openDatabase(atPath: databaseURL.path)
        return dbQueue
    }
    
    func getDBqueue() -> DatabaseQueue {
        return self.dbQueue
    }
    
    func getCalibrePath() -> URL {
        return self.calibrePath
    }
//    
//    func getBooks() -> [Book] {
//        var books: [Book]?
//        
//        let calibreDB = CalibreDB(settingStore: settingStore)
//        let dbQueue = calibreDB.load()
//
//        do {
//            try dbQueue.read { db -> [Book] in
//                books = try Book.limit(100).fetchAll(db)
//                return books!
//            }
//        } catch {
//            NSLog("Error: Unable to get books")
//        }
//        return books!
//    }
    
//    private func setupDatabase(_ application: UIApplication) throws {
//        let databaseURL = try Bundle.main.resourceURL!.appendingPathComponent("Test Database").appendingPathComponent("metadata.db")
//
//        dbQueue = try AppDatabase.openDatabase(atPath: databaseURL.path)
//
//        NSLog(databaseURL.path)
//
//        // Be a nice iOS citizen, and don't consume too much memory
//        // See https://github.com/groue/GRDB.swift/blob/master/README.md#memory-management
//        dbQueue.setupMemoryManagement(in: application)
//    }
}
