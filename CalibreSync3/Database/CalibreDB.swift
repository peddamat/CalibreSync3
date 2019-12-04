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
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            throw ErrorsToThrow.documentsDirectoryMissing // Could not find documents URL
        }
        
        let finalDatabaseURL = documentsUrl.first!.appendingPathComponent("metadata-cache.db")

        if self.settingStore.calibreRoot == nil {
            NSLog("Fuck")
        }
        guard let calibrePath = try settingStore.getCalibreURL() as URL? else {
            // Uncomment this to simulate that weird exception you experienced earlier...
            //self.settingStore.calibreRoot = nil
            throw ErrorsToThrow.calibrePathNotResolving
        }
        self.calibrePath = calibrePath
        
        // Cache a local copy of the database if we don't already have one
        if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false) {
            NSLog("Can't find a cached copy of the database...")
            
            let documentsURL = calibrePath.appendingPathComponent("metadata.db")
            
            do {
                NSLog("... caching copy of database")
                try fileManager.copyItem(atPath: documentsURL.path, toPath: finalDatabaseURL.path)
                  } catch let error as NSError {
                    NSLog("Couldn't cache the database! Error:\(error.description)")
            }

        }
        
        self.dbQueue = try! CalibreDB.openDatabase(atPath: finalDatabaseURL.path)
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
