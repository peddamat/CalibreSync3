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
    @Published var books = [Book]()
    
    init() {
    }
    
    func getBooks(calibreDB: CalibreDB, limit: Int = 100) {
        print("Getting books!")
//        DispatchQueue.global(qos: .userInitiated).async {

            do {
                let dbQueue = try calibreDB.load()
                try dbQueue.read { db in
                    let newBooks = try Book.limit(limit).fetchAll(db)
//                    DispatchQueue.main.async {
                        print("Retrieved books")
                        self.books.append(contentsOf: newBooks)
//                    }
                }
            } catch {
                print("Error: Unable to get books")
            }
//        }
        
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.task = URLSession.shared.dataTask(with: url) { data, response, error in
//                guard let data = data else { return }
//                DispatchQueue.main.async {
//                    self.data = data
//                }
//            }
//            self.task.resume()
//        }
    }
    
    func removeBook() {
        self.books.removeFirst()
    }
}
