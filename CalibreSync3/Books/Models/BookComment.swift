//
//  BookComments.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/2/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB

// Book
struct BookComment {
    
    var id: Int64
    var text: String

    static let databaseTableName = "Comments"
}

extension BookComment: Hashable { }

// MARK: - Persistence

extension BookComment: Codable, Identifiable, MutablePersistableRecord {
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let text = Column(CodingKeys.text)
    }
}

// MARK: - Associations

extension BookComment: TableRecord, FetchableRecord, EncodableRecord {
    static let book = belongsTo(Book.self, using: ForeignKey(["book"]))
    var book: QueryInterfaceRequest<Book> {
        return request(for: BookComment.book)
    }
}
