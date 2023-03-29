////
////  BookViewModel.swift
////  CalibreSync3
////
////  Created by Sumanth Peddamatham on 12/15/19.
////  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
////
//
//import Foundation
//import GRDB
//
//class BookViewModel: ObservableObject {
//    
//    var bookCache: BookCache
//    var calibreDB: CalibreDB
//    var dbQueue: DatabaseQueue {
//        calibreDB.dbQueue
//    }
//    
//    init(bookCache: BookCache, calibreDB: CalibreDB) {
//        self.bookCache = bookCache
//        self.calibreDB = calibreDB
//    }
//    
//    func getActions(book: DiskBook) -> [(Int, String, URL, String, Bool)]? {
//        var buttons = [(Int, String, URL, String, Bool)]()
//        
//        do {
//            try dbQueue.read { db -> [(Int, String, URL, String, Bool)] in
//                let formats = try DiskBookFormat
//                    .filter(Column("book") == book.id)
//                    .fetchAll(db)
//                
//                for format in formats {
//                    let bookLocalPath = self.bookCache.getLocalFile(forBook: self.book, withFormat: format)
//                    let bookRemotePath = "file://" + self.bookCache.getRemoteFile(forBook: self.book, withFormat: format).path
//                    let isCached = self.bookCache.checkCached(forBook: self.book, withFormat: format)
//                    
//                    let button = (Int(book.id),
//                                  format.format,
//                                  bookLocalPath,
//                                  bookRemotePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
//                                  isCached)
//                    buttons.append(button)
//                }
//                return buttons
//            }
//        } catch {
//            NSLog("Error: Unable to get books")
//        }
//        return buttons
//    }
//    
//    func getComments() -> [DiskBookComment] {
//        do {
//            return try dbQueue.read { db in
//                //                try book.comments.fetchAll(db)
//                try DiskBookComment
//                    .filter(Column("book") == book.id)
//                    .fetchAll(db)
//            }
//        } catch {
//            return []
//        }
//    }
//}
