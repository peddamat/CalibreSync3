//
//  BookCache.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/3/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI
import Combine
import PromiseKit
import GRDB

class BookCache: ObservableObject {
    var settingStore: SettingStore

//    @Published var books = [Book]()
    var didChange = PassthroughSubject<[DiskBook], Never>()
    var books = [DiskBook]() {
        didSet {
            didChange.send(books)
        }
    }
    
    init(settingStore: SettingStore) {
        self.settingStore = settingStore
    }
    
    func getBooks(calibreDB: CalibreDB, offset: Int = 0) {
        
        let limit = 2000
        var newBooks: QueryInterfaceRequest<DiskBook>? = nil
        
        switch self.settingStore.gridDisplayOrder {
        case .title:
            newBooks = DiskBook.order(DiskBookColumns.title)
        case .author:
            newBooks = DiskBook.order(DiskBookColumns.author_sort)
        case .calibreDateAdded:
            newBooks = DiskBook.order(DiskBookColumns.timestamp)
        case .downloadedDate:
            newBooks = DiskBook.order(DiskBookColumns.author_sort)
        }
        
        switch self.settingStore.gridDisplayDirection {
        case .ascending:
            break
        case .descending:
            newBooks = newBooks?.reversed()
        }
        
//        if books.isEmpty {
            NSLog("Getting books!")
            DispatchQueue.global(qos: .userInitiated).async {

                do {
                    let dbQueue = try calibreDB.load()
                    try dbQueue.read { db in
                        let fetchBooks = try newBooks!.limit(limit, offset: offset).fetchAll(db)
                        DispatchQueue.main.async {
                            NSLog("Retrieved \(fetchBooks.count) books")
//                            self.books.append(contentsOf: fetchBooks)
                            self.books = fetchBooks
                        }
                    }
                } catch {
                    NSLog("Error: Unable to get books")
                }
            }
//        }
    }
        
    func getCover(forBook: DiskBook) -> URL {
        return URL(fileURLWithPath: self.settingStore.localLibraryURL!.path + "/" + forBook.path + "/cover.jpg")
    }
    
    func getRemoteFile(forBook book: DiskBook, withFormat format: DiskBookFormat) -> URL {
        let tempPath = self.settingStore.remoteLibraryPath! + "/" + book.path + "/" + format.name + "." + format.format.lowercased()
        return URL(fileURLWithPath: tempPath)
    }

    func getLocalFile(forBook book: DiskBook, withFormat format: DiskBookFormat) -> URL {
        let tempPath = self.settingStore.localLibraryPath! + "/" + book.path + "/" + format.name + "." + format.format.lowercased()
        return URL(fileURLWithPath: tempPath)
    }
    
    func checkCached(forBook book: DiskBook, withFormat format: DiskBookFormat) -> Bool {
        let tempPath = self.settingStore.localLibraryPath! + "/" + book.path + "/" + format.name + "." + format.format.lowercased()
        
        return FileManager.default.fileExists(atPath: tempPath)
    }
    
    func removeBook() {
        NSLog("Remove")
        self.books.removeLast()
    }
}
