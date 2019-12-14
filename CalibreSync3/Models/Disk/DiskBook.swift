//
//  Books.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Foundation
import GRDB

// Author
struct DiskBook {
    var id: Int64
    var title: String
    var timestamp: Date
    var pubdate: Date
    var path: String
    var has_cover: Bool
    var author_sort: String
    var uuid: String
    
    // Custom columns
    var downloaded: Bool?
    
    static let databaseTableName = "Books"
}

enum DiskBookColumns: String, ColumnExpression {
    case title
    case timestamp
    case pubdate
    case author_sort
}

extension DiskBook: Hashable { }

// MARK: - Persistence

extension DiskBook: Codable, Identifiable, MutablePersistableRecord {
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let path = Column(CodingKeys.path)
//        static let format = Column(CodingKeys.format)
        static let has_cover = Column(CodingKeys.has_cover)
        static let author = Column(CodingKeys.author_sort)
        static let uuid = Column(CodingKeys.uuid)
    }
}

// MARK: - Persistence

extension DiskBook {
    static func orderedByName() -> QueryInterfaceRequest<DiskBook> {
        return DiskBook.order(Columns.title)
    }
}

// MARK: - Associations

extension DiskBook: TableRecord, FetchableRecord, EncodableRecord {
    static let comments = hasMany(DiskBookComment.self)
    var comments: QueryInterfaceRequest<DiskBookComment> {
        return request(for: DiskBook.comments)
    }
}
