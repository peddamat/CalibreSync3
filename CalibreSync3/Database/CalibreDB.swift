//
//  CalibreDB.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB
import SwiftUI

struct CalibreDB {
    var settingStore: SettingStore
    
    /// Creates a fully initialized database at path
    static func openDatabase(atPath path: String) throws -> DatabaseQueue {
        // Connect to the database
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
        let dbQueue = try DatabaseQueue(path: path)
        
        // Define the database schema
        //try migrator.migrate(dbQueue)

        return dbQueue
    }
    
    func load() -> DatabaseQueue {
        let calibrePath = settingStore.getCalibreURL() as URL
        let databaseURL = try! calibrePath.appendingPathComponent("metadata.db")

        let dbQueue = try! CalibreDB.openDatabase(atPath: databaseURL.path)
        return dbQueue
    }
    
//    private func setupDatabase(_ application: UIApplication) throws {
//        let databaseURL = try Bundle.main.resourceURL!.appendingPathComponent("Test Database").appendingPathComponent("metadata.db")
//
//        dbQueue = try AppDatabase.openDatabase(atPath: databaseURL.path)
//
//        print(databaseURL.path)
//
//        // Be a nice iOS citizen, and don't consume too much memory
//        // See https://github.com/groue/GRDB.swift/blob/master/README.md#memory-management
//        dbQueue.setupMemoryManagement(in: application)
//    }
}
