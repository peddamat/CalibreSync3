//
//  BookCache.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/3/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI
import Combine

class BookCache: ObservableObject {
//    @Published var books = [Book]()
    var didChange = PassthroughSubject<[Book], Never>()
    var books = [Book]() {
        didSet {
            didChange.send(books)
        }
    }
    
    init() {
    }
    
    func getBooks(calibreDB: CalibreDB, limit: Int = 100, offset: Int = 0) {
        if books.isEmpty {
            NSLog("Getting books!")
            DispatchQueue.global(qos: .userInitiated).async {

                do {
                    let dbQueue = try calibreDB.load()
                    try dbQueue.read { db in
                        let newBooks = try Book.limit(limit, offset: offset).fetchAll(db)
                        DispatchQueue.main.async {
                            NSLog("Retrieved \(newBooks.count) books")
                            self.books.append(contentsOf: newBooks)
                        }
                    }
                } catch {
                    NSLog("Error: Unable to get books")
                }
            }
        }
    }
    
//    static func cacheBookCovers(calibreDB: CalibreDB) {
//        NSLog("Getting books!")
//        DispatchQueue.global(qos: .userInitiated).async {
//
//            do {
//                let dbQueue = try calibreDB.load()
//                try dbQueue.read { db in
//                    let newBooks = try Book.fetchAll(db)
//
//                    for book in
//                    DispatchQueue.main.async {
//                        NSLog("Retrieved \(newBooks.count) books")
//                        self.books.append(contentsOf: newBooks)
//                    }
//                }
//            } catch {
//                NSLog("Error: Unable to get books")
//            }
//        }
//    }
    
    func removeBook() {
        NSLog("Remove")
        self.books.removeLast()
    }
    
    func getBookCoverURL(settingStore: SettingStore, book: Book) -> URL {
        return URL(fileURLWithPath: settingStore.calibreRemoteLibraryPath! + "/" + book.path + "/cover.jpg")
    }
    
    func getBookFileURL(settingStore: SettingStore, book: Book, format: BookFormat) -> URL {
        let tempPath = settingStore.calibreRemoteLibraryPath! + "/" + book.path + "/" + format.name + "." + format.format.lowercased()
        return URL(fileURLWithPath: tempPath)
    }
    
    static func findAllBookCovers(pickedFolderURL: URL) -> [URL] {
        var coverURLs: [URL] = []
        let error: NSErrorPointer = nil
        
        let urlCount = pickedFolderURL.path.count
        
        let shouldStopAccessing = pickedFolderURL.startAccessingSecurityScopedResource()
        defer { if shouldStopAccessing { pickedFolderURL.stopAccessingSecurityScopedResource() }}

        NSFileCoordinator().coordinate(readingItemAt: pickedFolderURL, error: error)
        { (folderURL) in
            
            NSLog("Starting book cover scan...")
            let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
                            
            let directoryEnumerator = FileManager.default.enumerator(at: folderURL, includingPropertiesForKeys: Array(resourceKeys))
            for case let fileURL as URL in directoryEnumerator! {
                guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                    let isDirectory = resourceValues.isDirectory,
                    let name = resourceValues.name
                    else {
                        continue
                }
                if !isDirectory && name == "cover.jpg" {
                    let foundCover = fileURL.path.dropFirst(urlCount)
                    NSLog("Found cover at: \(foundCover)")
                    coverURLs.append(URL(fileURLWithPath: String(foundCover)))
                }
            }
        }
        
        return coverURLs
    }
}
