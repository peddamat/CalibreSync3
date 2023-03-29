//
//  BookFormat.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/3/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB

struct DiskBookFormat {

  var id: Int64
  var format: String
  var name: String

  static let databaseTableName = "Data"
}

extension DiskBookFormat: Hashable {}

// MARK: - Persistence

extension DiskBookFormat: Codable, Identifiable, MutablePersistableRecord {
  private enum Columns {
    static let id = Column(CodingKeys.id)
    static let format = Column(CodingKeys.format)
    static let name = Column(CodingKeys.name)
  }
}

// MARK: - Associations
extension DiskBookFormat: TableRecord, FetchableRecord, EncodableRecord {
  static let book = belongsTo(DiskBook.self, using: ForeignKey(["book"]))
  var book: QueryInterfaceRequest<DiskBook> {
    return request(for: DiskBookFormat.book)
  }
}
