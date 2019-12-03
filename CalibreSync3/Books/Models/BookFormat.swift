//
//  BookFormat.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/3/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB

struct BookFormat {
    
    var id: Int64
    var format: String
    var name: String

    static let databaseTableName = "Data"
}

extension BookFormat: Hashable { }

// MARK: - Persistence

extension BookFormat: Codable, Identifiable, MutablePersistableRecord {
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let format = Column(CodingKeys.format)
        static let name = Column(CodingKeys.name)
    }
}

// MARK: - Associations



