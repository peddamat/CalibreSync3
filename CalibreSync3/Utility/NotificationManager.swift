//
//  NotificationManager.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/10/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let downloadProgressUpdate = Notification.Name("downloadProgressUpdate")
    static let refreshBookCache = Notification.Name("refreshBookCache")
    static let loadMoreBookCache = Notification.Name("loadMoreBookCache")
    static let openBook = Notification.Name("openBook")
}
