//
//  SettingsStore.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Combine
import Foundation

final class SettingStore: ObservableObject {
    @Published var defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        defaults.register(defaults: [
            "view.preferences.calibreLibraryPath": "/"
        ])
    }
    
    var calibreRoot: Data {
        get {
            defaults.data(forKey: "view.preferences.calibreLibraryPath")!
        }
        
        set {
            defaults.set(newValue, forKey: "view.preferences.calibreLibraryPath")
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    func getCalibreURL() -> URL {
        var urlResult = false
        return try! URL(resolvingBookmarkData: calibreRoot, options: [], relativeTo: nil, bookmarkDataIsStale: &urlResult)
    }
    
    func getCalibrePath() -> String {
        return getCalibreURL().path
    }
}
