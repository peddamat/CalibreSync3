//
//  ErrorsToThrow.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/13/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Foundation

enum ErrorsToThrow: Error {
    case calibrePathNotSet
    case calibrePathNotResolving
    case documentsDirectoryMissing
    case calibreLocalDatabaseMissing
}
