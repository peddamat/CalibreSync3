//
//  BookComments.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/2/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB

// Book
struct DiskBookComment {

  var id: Int64
  var text: String

  static let databaseTableName = "Comments"
}

extension DiskBookComment: Hashable {}

// MARK: - Persistence

extension DiskBookComment: Codable, Identifiable, MutablePersistableRecord {
  private enum Columns {
    static let id = Column(CodingKeys.id)
    static let text = Column(CodingKeys.text)
  }
}

// MARK: - Associations

extension DiskBookComment: TableRecord, FetchableRecord, EncodableRecord {
  static let book = belongsTo(DiskBook.self, using: ForeignKey(["book"]))
  var book: QueryInterfaceRequest<DiskBook> {
    return request(for: DiskBookComment.book)
  }
}
