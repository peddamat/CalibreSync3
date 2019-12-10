//
//  CalibreDB.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB
import SwiftUI
import PromiseKit

class CalibreDB {
    var settingStore: SettingStore
    private var dbQueue: DatabaseQueue
    private let fileManager = FileManager.default
    
    init(settingStore: SettingStore) throws {
        self.settingStore = settingStore
        
        let localDBURL = try SettingStore.calibreLocalDBURL()

        if !( (try? localDBURL.checkResourceIsReachable()) ?? false) {
            NSLog("Can't find a cached copy of the database at \(localDBURL.path)")
            throw ErrorsToThrow.calibreLocalDatabaseMissing
        }

        self.dbQueue = try! CalibreDB.openDatabase(atPath: localDBURL.path)
    }

    static func cacheRemoteCalibreDB(settingStore: SettingStore, calibreRemoteURL: URL) throws {
        let localDBURL = try SettingStore.calibreLocalDBURL()        
        let documentsURL = calibreRemoteURL.appendingPathComponent("metadata.db")
        
        do {
            NSLog("... caching copy of database")
            let shouldStopAccessing = calibreRemoteURL.startAccessingSecurityScopedResource()
            defer { if shouldStopAccessing { calibreRemoteURL.stopAccessingSecurityScopedResource() }}

            try FileManager.default.copyItem(atPath: documentsURL.path, toPath: localDBURL.path)
            NSLog("Database cached!")
              } catch let error as NSError {
                NSLog("Couldn't cache the database! Error:\(error.description)")
        }
    }
    
    static func promiseCacheRemoteCalibreDB(localDirectory: URL, remoteDBURL: URL) -> Promise<URL> {
        return Promise<URL> { seal in
            do {
                let localDBURL = localDirectory.appendingPathComponent("metadata.db")

                NSLog("... caching copy of database")
                try FileManager.default.copyItem(atPath: remoteDBURL.path, toPath: localDBURL.path)
                NSLog("Database cached!")
                
                seal.fulfill(localDBURL)
            } catch let error as NSError {
                NSLog("Couldn't cache the database! Error:\(error.description)")
                seal.reject(error)
            }
        }
    }
    

    
    static func promiseOpenDatabase(atPath path: String) -> Promise<DatabaseQueue> {
        return Promise<DatabaseQueue> { seal in
            do {
                NSLog("Opening database at: \(path)")
                let dbQueue = try DatabaseQueue(path: path)
                seal.resolve(.fulfilled(dbQueue))
            } catch {
                seal.reject(error)
            }
        }
    }
    
    static func openDatabase(atPath path: String) throws -> DatabaseQueue {
        let dbQueue = try DatabaseQueue(path: path)
        
        //try migrator.migrate(dbQueue)

        return dbQueue
    }
    
    func load() throws  -> DatabaseQueue {
        let localDBURL = try SettingStore.calibreLocalDBURL()
        let dbQueue = try! CalibreDB.openDatabase(atPath: localDBURL.path)
        
        return dbQueue
    }
    
    func getDBqueue() -> DatabaseQueue {
        return self.dbQueue
    }
    
//    func getCalibrePath() -> URL {
//        return self.calibrePath
//    }
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
