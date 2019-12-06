//
//  SettingsStore.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Combine
import Foundation

enum ErrorsToThrow: Error {
    case calibrePathNotSet
    case calibrePathNotResolving
    case documentsDirectoryMissing
    case calibreLocalDatabaseMissing
}

final class SettingStore: ObservableObject {
    @Published var defaults: UserDefaults
    @Published var searchString: String = ""
    
    init(defaults: UserDefaults = .standard, searchString: String = "") {
        self.defaults = defaults
        self.searchString = searchString
        
        defaults.register(defaults: [
            "view.preferences.calibreLibraryPath": "/"
        ])
    }
    
    var calibreRemoteLibraryBookmark: Data? {
        get {
            defaults.data(forKey: "view.preferences.calibreLibraryPath")
        }
        
        set {
            defaults.set(newValue, forKey: "view.preferences.calibreLibraryPath")
            self.objectWillChange.send()
        }
    }
    
    var calibreRemoteLibraryURL: URL? {
        get {
            if self.calibreRemoteLibraryBookmark == nil {
                return nil
            } else {
                var urlResult = false
                
                guard let calibreRoot = calibreRemoteLibraryBookmark else {
                    return nil
                }
                
                do {
                    return try URL(resolvingBookmarkData: calibreRoot, options: [], relativeTo: nil, bookmarkDataIsStale: &urlResult)
                } catch {
                    return nil
                }
            }
        }
    }
    
    var calibreRemoteLibraryPath: String? {
        get {
            guard self.calibreRemoteLibraryURL != nil else {
                return nil
            }
            return self.calibreRemoteLibraryURL?.path
        }
    }
    
    static func calibreLocalDBURL() throws -> URL {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            throw ErrorsToThrow.documentsDirectoryMissing // Could not find documents URL
        }
        return documentsUrl.first!.appendingPathComponent("metadata-cache.db")
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    func saveCalibrePath(_ url: URL) {
        NSLog(url.path)
        
        do {
            let shouldStopAccessing = url.startAccessingSecurityScopedResource()
            defer { if shouldStopAccessing { url.stopAccessingSecurityScopedResource() } }
            
            let bookmark = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            self.calibreRemoteLibraryBookmark = bookmark
        } catch let error {
            
        }
    }
    
    func getCalibreURL() throws -> URL {
        var urlResult = false
        guard let calibreRoot = calibreRemoteLibraryBookmark else {
            throw ErrorsToThrow.calibrePathNotSet
        }
        
        do {
            return try URL(resolvingBookmarkData: calibreRoot, options: [], relativeTo: nil, bookmarkDataIsStale: &urlResult)
        } catch {
            if urlResult {
                NSLog("Bookmark data has expired!")
            }
            else {
                NSLog("Can't retrieve the bookmark data, wtf!")
            }
            throw ErrorsToThrow.calibrePathNotResolving
        }
    }
    
    func getCalibrePath() throws -> String {
        return try getCalibreURL().path
    }
}
