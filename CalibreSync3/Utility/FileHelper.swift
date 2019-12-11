//
//  FileHelper.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/6/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Foundation
import PromiseKit

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
    
    static func promiseCopyBookCovers(covers: [String], pickedFolderURL: URL, destinationFolderURL: URL) -> Promise<Bool> {
        return Promise<Bool> { seal in

            DispatchQueue.global(qos: .userInitiated).async {
                for coverURL in covers {
                    
//                    let srcFile = pickedFolderURL.appendingPathComponent(coverURL.path).appendingPathComponent("cover.jpg")
//                    let srcFile = coverURL.appendingPathComponent("cover.jpg")
                    let srcDirectory = pickedFolderURL.appendingPathComponent(coverURL)
                    let srcFile = srcDirectory.appendingPathComponent("cover.jpg")
                    let dstDirectory = destinationFolderURL.appendingPathComponent(coverURL)
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
                    
//                    FileHelper.accessSecurityScopedFolder(url: pickedFolderURL)
                    let shouldStopAccessing = srcFile.startAccessingSecurityScopedResource()
                    defer { if shouldStopAccessing { srcFile.stopAccessingSecurityScopedResource() }}
                    
                    do {
                        NSLog("Copying cover to: \(dstFile.path)")
                        try FileManager.default.copyItem(at: srcFile, to: dstFile)
                    } catch {
                        NSLog("Couldn't copy file from: \(srcFile.path)")
                        print(error)
//                        seal.reject(error)                        
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
