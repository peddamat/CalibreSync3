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
    
    func getBooks(calibreDB: CalibreDB, limit: Int = 100) {
        if books.isEmpty {
            NSLog("Getting books!")
            DispatchQueue.global(qos: .userInitiated).async {

                do {
                    let dbQueue = try calibreDB.load()
                    try dbQueue.read { db in
                        let newBooks = try Book.limit(limit).fetchAll(db)
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
    
    func removeBook() {
        self.books.removeLast()
    }
}
