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
    let urlString: String
    @Binding var progress: Float
    
//    init(remoteURL url: String, progress: Float) {
//        self.urlString = url
////        self.progress = progress
//    }
    
    func beginDownloadingFile(){
        print("Downloading Started.......")
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: configuration, delegate: DownloaderDelegate(bookID: bookID, progress: $progress), delegateQueue: operationQueue)
        print(urlString)
        guard let url = URL(string: urlString) else {
            print("URL Not valid")
            return
        }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
        
    private class DownloaderDelegate: NSObject, URLSessionDownloadDelegate {
        let bookID: Int
        var progress: Binding<Float>
        
        init(bookID: Int, progress: Binding<Float>) {
            self.bookID = bookID
            self.progress = progress
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            print("Finshed Downloading Files")
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
            print("TotalBytes:- ", totalBytesWritten, "and toBytesWrittenExpected:- ", totalBytesExpectedToWrite)
            
            let percentage = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            self.progress.wrappedValue = percentage
            
    //        DispatchQueue.main.async {
    //          NSLog("\(Int(percentage * 100))%")
    //        }
            
            let userInfo = ["bookID": bookID, "percentage": percentage] as [String : Any]
            NotificationCenter.default.post(name: .downloadProgressUpdate, object: nil, userInfo: userInfo)
            
            print("Percentage Downloaded:- ", percentage)
        }
    }
}
