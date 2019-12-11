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
    @Published var loadingMore: Bool = false
    
    init(defaults: UserDefaults = .standard, searchString: String = "", loadingMore: Bool = false) {
        self.defaults = defaults
        self.searchString = searchString
        self.loadingMore = loadingMore
        
        defaults.register(defaults: [
            "view.preferences.calibreLibraryPath": "/"
        ])
    }
    
    func saveRemoteLibraryBookmark(_ url: URL) {
        NSLog(url.path)
        
        do {
            let shouldStopAccessing = url.startAccessingSecurityScopedResource()
            defer { if shouldStopAccessing { url.stopAccessingSecurityScopedResource() } }
            
            let bookmark = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            self.remoteLibraryBookmark = bookmark
        } catch let error {
            
        }
    }
    
    var remoteLibraryBookmark: Data? {
        get {
            defaults.data(forKey: "view.preferences.calibreLibraryPath")
        }
        
        set {
            defaults.set(newValue, forKey: "view.preferences.calibreLibraryPath")
            self.objectWillChange.send()
        }
    }
    
    var remoteLibraryURL: URL? {
        get {
            if self.remoteLibraryBookmark == nil {
                return nil
            } else {
                var urlResult = false
                
                guard let calibreRoot = remoteLibraryBookmark else {
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
    
    var remoteLibraryPath: String? {
        get {
            guard self.remoteLibraryURL != nil else {
                return nil
            }
            return self.remoteLibraryURL?.path
        }
    }
        
    var localLibraryURL: URL? {
        return FileHelper.getDocumentsDirectory()
    }
    
    var localLibraryPath: String? {
        get {
            guard self.localLibraryURL != nil else {
                return nil
            }
            return self.localLibraryURL?.path
        }
    }
    
    var localDBURL: URL? {
        get {
            guard self.localLibraryURL != nil else {
                return nil
            }
            return self.localLibraryURL!.appendingPathComponent("metadata.db")
        }
    }
        
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
}
