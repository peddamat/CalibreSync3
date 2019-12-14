//
//  Downloader.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/10/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Foundation
import SwiftUI

struct Downloader {
    let bookID: Int
    let localFileURL: URL
    let remoteFilePath: String
    @Binding var progress: Float
    
//    init(remoteURL url: String, progress: Float) {
//        self.urlString = url
////        self.progress = progress
//    }
    
    func beginDownloadingFile(){
        NSLog("Downloading Started.......")
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: configuration, delegate: DownloaderDelegate(bookID: bookID, progress: $progress, localFileURL: localFileURL), delegateQueue: operationQueue)
        NSLog(remoteFilePath)
        guard let url = URL(string: remoteFilePath) else {
            NSLog("URL Not valid")
            return
        }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
        
    private class DownloaderDelegate: NSObject, URLSessionDownloadDelegate {
        let bookID: Int
        var progress: Binding<Float>
        var localFileURL: URL
        
        init(bookID: Int, progress: Binding<Float>, localFileURL: URL) {
            self.bookID = bookID
            self.progress = progress
            self.localFileURL = localFileURL
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            NSLog("Finished download!")
            print("Moving file from: \(location)")
            print("to: \(self.localFileURL)")
            
            try! FileManager.default.moveItem(at: location,to: self.localFileURL)
                        
            let userInfo = ["bookID": bookID] as [String : Any]
            NotificationCenter.default.post(name: .downloadComplete, object: nil, userInfo: userInfo)
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
            
            let percentage = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            self.progress.wrappedValue = percentage
            
    //        DispatchQueue.main.async {
    //          NSLog("\(Int(percentage * 100))%")
    //        }
            
            // TODO: Replace with struct
            let userInfo = ["bookID": bookID, "percentage": percentage, "localURL": localFileURL.path] as [String : Any]
            NotificationCenter.default.post(name: .downloadProgressUpdate, object: nil, userInfo: userInfo)
            
            NSLog("Percentage Downloaded:- ", percentage)
        }
    }
}
