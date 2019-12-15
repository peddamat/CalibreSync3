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
    @ObservedObject var store = Store.shared
    private var _dbQueue: DatabaseQueue
    private let fileManager = FileManager.default
    
    init(store: Store) throws {
        self.store = store
        
        let localDBURL = store.localDBURL!

        if !( (try? localDBURL.checkResourceIsReachable()) ?? false) {
            NSLog("Can't find a cached copy of the database at \(localDBURL.path)")
            throw ErrorsToThrow.calibreLocalDatabaseMissing
        }

        self._dbQueue = try! DatabaseQueue(path: localDBURL.path)
        setupNotifications()
    }
    
    func load() throws  -> DatabaseQueue {
        let localDBURL = store.localDBURL!

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
    
    func update(book: DiskBook, in dbQueue: DatabaseQueue) throws {
        try dbQueue.write { db in
            try book.update(db)
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

                // Make database file writable so we can run migrations
                let attributes: [FileAttributeKey:AnyObject] = [FileAttributeKey.posixPermissions: NSNumber(value: 0o666)]
                try! FileManager.default.setAttributes(attributes, ofItemAtPath: localDBURL.path)
                
                if FileManager.default.isWritableFile(atPath: localDBURL.path) {
                    print("File is writeable!")
                }
                
                if FileManager.default.isWritableFile(atPath: localDirectory.path) {
                    print("Directory is writeable!")
                }
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

                var migrator = DatabaseMigrator()
                // 1st migration
                migrator.registerMigration("addDownloadsToBooks") { db in
                    try db.alter(table: "Books") { t in
                        t.add(column: "downloaded", .boolean)
                    }
                    try db.execute(sql: "DROP TRIGGER books_update_trg")
                }
                try migrator.migrate(dbQueue)

                seal.resolve(.fulfilled(dbQueue))
            } catch {
                seal.reject(error)
            }
        }
    }
    
    static func getBookCoverURLs(dbQueue: DatabaseQueue, withBaseURL: URL) -> Promise<[String]> {
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
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .downloadComplete, object: nil, queue: .main) { (notification) in
            if let data = notification.userInfo as? [String: Any]
            {
//                if (data["bookID"]! as! Int == self.bookID) {
//                }
                do {
                    let dbQueue = try self.load()
                    let bookCache = BookCache()
                    try! bookCache.setCached(forBookID: data["bookID"] as! Int, in: dbQueue)
                } catch {
                    
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
//                        let bookPath = BookCache.getBookFileURL(store: self.store, book: book, format: format)
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
