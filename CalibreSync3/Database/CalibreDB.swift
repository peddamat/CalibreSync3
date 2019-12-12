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
    private var _dbQueue: DatabaseQueue
    private let fileManager = FileManager.default
    
    init(settingStore: SettingStore) throws {
        self.settingStore = settingStore
        
        let localDBURL = settingStore.localDBURL!

        if !( (try? localDBURL.checkResourceIsReachable()) ?? false) {
            NSLog("Can't find a cached copy of the database at \(localDBURL.path)")
            throw ErrorsToThrow.calibreLocalDatabaseMissing
        }

        self._dbQueue = try! DatabaseQueue(path: localDBURL.path)
    }
    
    func load() throws  -> DatabaseQueue {
        let localDBURL = settingStore.localDBURL!

        if !( (try? localDBURL.checkResourceIsReachable()) ?? false) {
            NSLog("Can't find a cached copy of the database at \(localDBURL.path)")
            throw ErrorsToThrow.calibreLocalDatabaseMissing
        }
    
        return try DatabaseQueue(path: localDBURL.path)
    }
        
    var dbQueue: DatabaseQueue {
        get {
            return self._dbQueue
        }
    }
    
    static func copyDatabase(at remoteDirectory: URL, to localDirectory: URL) -> Promise<URL> {
        return Promise<URL> { seal in
            do {
                let shouldStopAccessing = remoteDirectory.startAccessingSecurityScopedResource()
                defer { if shouldStopAccessing { remoteDirectory.stopAccessingSecurityScopedResource() } }

                let remoteDBURL = remoteDirectory.appendingPathComponent("metadata.db")
                let localDBURL = localDirectory.appendingPathComponent("metadata.db")
                
                NSLog("... caching copy of database")
                try FileManager.default.copyItem(at: remoteDBURL, to: localDBURL)
                NSLog("Database cached!")
                
                seal.fulfill(localDBURL)
            } catch let error as NSError {
                NSLog("Couldn't cache the database! Error:\(error.description)")
                seal.reject(error)
            }
        }
    }
    
    static func openDatabase(atPath path: String) -> Promise<DatabaseQueue> {
        return Promise<DatabaseQueue> { seal in
            do {
                NSLog("Opening database at: \(path)")
                let dbQueue = try DatabaseQueue(path: path)

//                var migrator = DatabaseMigrator()
//                // 1st migration
//                migrator.registerMigration("addDownloadsToBooks") { db in
//                    try db.alter(table: "Books") { t in
//                        t.add(column: "downloaded", .text)
//                    }
//                }
//                try migrator.migrate(dbQueue)

                seal.resolve(.fulfilled(dbQueue))
            } catch {
                seal.reject(error)
            }
        }
    }
    
    static func promiseGetBookCoverURLs(dbQueue: DatabaseQueue, withBaseURL: URL) -> Promise<[String]> {
        func createURL(baseURL: URL, bookPath: String) -> String {
//            let bookCoverURL = baseURL.appendingPathComponent(bookPath).appendingPathComponent("cover.jpg")
//            let bookCoverURL = baseURL.appendingPathComponent(bookPath)
//            let bookCoverURL = URL(string: "/" + bookPath + "/")!
            return bookPath
        }
        
        return Promise<[String]> { seal in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try dbQueue.read { db in
                        let newBooks = try DiskBook.fetchAll(db)
                        let bookCoverURLs = newBooks.compactMap { createURL(baseURL: withBaseURL, bookPath: $0.path) }
                        seal.fulfill(bookCoverURLs)
                    }
                } catch {
                    NSLog("Error: Unable to get books")
                    seal.reject(error)
                }
            }
        }
    }
    
//    static func promiseGetDownloadURLs(book: DiskBook, dbQueue: DatabaseQueue, withBaseURL: URL) -> Promise<[String]> {
//        return Promise<[String]> { seal in
//            var buttons = [String]()
//
//            do {
//                try dbQueue.read { db -> [String] in
//                    let formats = try DiskBookFormat
//                        .filter(Column("book") == book.id)
//                        .fetchAll(db)
//
//                    for format in formats {
//                        let bookPath = BookCache.getBookFileURL(settingStore: self.settingStore, book: book, format: format)
//                        NSLog("Copying book in: \(bookPath!.path)")
//
//                        buttons.append(bookPath)
//                    }
//
//                    seal.fulfill(buttons)
//                }
//            } catch {
//                NSLog("Error: Unable to get books")
//                seal.reject(error)
//            }
//        }
//    }
}
