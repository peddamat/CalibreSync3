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
}

final class SettingStore: ObservableObject {
    @Published var defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        defaults.register(defaults: [
            "view.preferences.calibreLibraryPath": "/"
        ])
    }
    
    var calibreRoot: Data? {
        get {
            defaults.data(forKey: "view.preferences.calibreLibraryPath")
        }
        
        set {
            defaults.set(newValue, forKey: "view.preferences.calibreLibraryPath")
            self.objectWillChange.send()
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    func getCalibreURL() throws -> URL {
        var urlResult = false
        guard let calibreRoot = calibreRoot else {
            throw ErrorsToThrow.calibrePathNotSet
        }
        
        do {
            return try URL(resolvingBookmarkData: calibreRoot, options: [], relativeTo: nil, bookmarkDataIsStale: &urlResult)
        } catch {
            throw ErrorsToThrow.calibrePathNotResolving
        }
    }
    
    func getCalibrePath() throws -> String {
        return try getCalibreURL().path
    }
}
