//
//  Books.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB

struct Book {
    var id: Int64
    var title: String
    var path: String
    var has_cover: Bool
    var uuid: String
    
    static let databaseTableName = "Books"
}

extension Book: Hashable { }

// MARK: - Persistence

extension Book: Codable, Identifiable, FetchableRecord, MutablePersistableRecord {
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let path = Column(CodingKeys.path)
//        static let format = Column(CodingKeys.format)
        static let has_cover = Column(CodingKeys.has_cover)
        static let uuid = Column(CodingKeys.uuid)
    }
}

// MARK: - Persistence

extension Book {
    static func orderedByName() -> QueryInterfaceRequest<Book> {
        return Book.order(Columns.title)
    }
}

