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
    
//    var didChange = PassthroughSubject<Bool, Never>()
//    @Published var loading: Bool = false {
//        didSet {
//            if oldValue == false && loading == true {
//                self.load()
//            }
//        }
//    }
//    
//    @Published var loadingMore: Bool = false {
//        didSet {
//            if oldValue == false && loadingMore == true {
//                didChange.send(loadingMore)
//            }
//        }
//    }
//    
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
    
    
    @Published(key: "view.preferences.itemsPerScreen")
    var itemsPerScreen = 33

//    public var displayOrders = ["Title", "Author", "Calibre Added Date", "Downloaded Date"]
    public enum DisplayOrders: String, CaseIterable, Hashable, Identifiable {
        case title = "Title"
        case author = "Author"
        case calibreDateAdded = "Calibre Added Date"
        case downloadedDate = "Downloaded Date"
        
        var id: DisplayOrders {self}
    }
    
    public enum DisplayDirections: String, CaseIterable, Hashable, Identifiable {
        case ascending = "Ascending"
        case descending = "Descending"
        
        var id: DisplayDirections {self}
    }
        
    @Published(key: "")
    var gridDisplayOrder = DisplayOrders.title
    
    @Published(key: "")
    var gridDisplayDirection = DisplayDirections.ascending
    
    @Published(key: "view.preferences.gridOnlyShowDownloaded")
    var gridOnlyShowDownloaded = false
    
//    @Published(key: "view.preferences.calibreLibraryPath")
//    var remoteLibraryBookmark: Data? = nil
    
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

// From: https://stackoverflow.com/questions/57611658/swiftui-how-to-persist-published-variable-using-userdefaults
private var cancellables = [String:AnyCancellable]()

extension Published {
    init(wrappedValue defaultValue: Value, key: String) {
        if key == "" {
            self.init(initialValue: defaultValue)
            return
        }
        let value = UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        self.init(initialValue: value)
        cancellables[key] = projectedValue.sink { val in
            UserDefaults.standard.set(val, forKey: key)
        }
    }
}


//extension SettingStore.DisplayOrders: Codable {
//
//    enum Key: CodingKey {
//        case rawValue
//    }
//
//    enum CodingError: Error {
//        case unknownValue
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: Key.self)
//        let rawValue = try container.decode(Int.self, forKey: .rawValue)
//        switch rawValue {
//        case 0:
//            self = .title
//        case 1:
//            self = .author
//        case 2:
//            self = .calibreDateAdded
//        default:
//            throw CodingError.unknownValue
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: Key.self)
//        switch self {
//        case .title:
//            try container.encode(0, forKey: .rawValue)
//        case .author:
//            try container.encode(1, forKey: .rawValue)
//        case .calibreDateAdded:
//            try container.encode(2, forKey: .rawValue)
//        case .downloadedDate:
//            try container.encode(3, forKey: .rawValue)
//        }
//    }
//
//}
