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
        let urlSession = URLSession(configuration: configuration, delegate: DownloaderDelegate(progress: $progress), delegateQueue: operationQueue)
        print(urlString)
        guard let url = URL(string: urlString) else {
            print("URL Not valid")
            return
        }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    func updateProgress(progress: Float) {
        self.progress = progress
    }
    
    private class DownloaderDelegate: NSObject, URLSessionDownloadDelegate {
        var progress: Binding<Float>
        
        init(progress: Binding<Float>) {
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
            
            print("Percentage Downloaded:- ", percentage)
        }
    }
}
