//
//  FileHelper.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/6/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftUI

class FileHelper {
    static func getDocumentsDirectory() -> URL? {
        if let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsPathURL
        }
        return nil
    }
    
    static func accessSecurityScopedFolder(url: URL) {
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
    }
    
    static func copyBookCovers(covers: [String], at remoteDirectory: URL, to localDirectory: URL, bookCount: Binding<CGFloat>) -> Promise<Bool> {
        return Promise<Bool> { seal in

            DispatchQueue.global(qos: .userInitiated).async {
                
                let shouldStopAccessing = remoteDirectory.startAccessingSecurityScopedResource()
                defer { if shouldStopAccessing { remoteDirectory.stopAccessingSecurityScopedResource() }}
                
                for coverURL in covers {
                    
                    let srcDirectory = remoteDirectory.appendingPathComponent(coverURL)
                    let srcFile = srcDirectory.appendingPathComponent("cover.jpg")
                    let dstDirectory = localDirectory.appendingPathComponent(coverURL)
                    let dstFile = dstDirectory.appendingPathComponent("cover.jpg")
                    
                    NSLog("Creating directory at: \(dstDirectory.path)")
                    do {
                        try FileManager.default.createDirectory(
                            atPath: dstDirectory.path,
                            withIntermediateDirectories: true,
                            attributes: nil
                        )
                    } catch {
                        NSLog("Couldn't create directory!")
                        print(error)
                        seal.reject(error)
                    }

                    // TODO: Create FileManager extension to copy from iCloud
                    let coordinator = NSFileCoordinator()
                    var error: NSError? = nil
                    coordinator.coordinate(readingItemAt: srcFile, options: [], error: &error) { (url) -> Void in
                        do {
                            NSLog("Copying cover to: \(dstFile.path)")
                                try FileManager.default.copyItem(at: url, to: dstFile)
                        } catch let error as NSError {
                            NSLog("Couldn't copy cover! Error:\(error.description)")
    //                        seal.reject(error)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        bookCount.wrappedValue += 1
                    }
                }
                
                seal.fulfill(true)
            }
        }
    }
    
    static func copyItem(fromPath: String, toPath: String) -> Bool
    {
        var success = true
        do {
            try FileManager.default.copyItem(atPath: fromPath, toPath: toPath)
        } catch {
            success = false
            NSLog("Couldn't copy file")
            NSLog(" From: \(fromPath)")
            NSLog(" To: \(toPath)")
            print("Error: \(error)")
        }
        return success
    }
}
