//
//  DownloadManager.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/10/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Foundation
import SwiftUI

struct DownloadManager {
  let bookID: Int
  let localFileURL: URL
  let remoteFilePath: String
  @Binding var progress: Float

  //    init(remoteURL url: String, progress: Float) {
  //        self.urlString = url
  ////        self.progress = progress
  //    }

  func getCloudDocument(url: URL) {
    let isSecuredURL = url.startAccessingSecurityScopedResource() == true
    let coordinator = NSFileCoordinator()
    var error: NSError? = nil
    coordinator.coordinate(readingItemAt: url, options: [], error: &error) { (url) -> Void in
      // Create file URL to temporary folder
      var tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
      // Apend filename (name+extension) to URL
      tempURL.appendPathComponent(url.lastPathComponent)
      do {
        // If file with same name exists remove it (replace file with new one)
        if FileManager.default.fileExists(atPath: tempURL.path) {
          try FileManager.default.removeItem(atPath: tempURL.path)
        }
        // Move file from app_id-Inbox to tmp/filename
        try FileManager.default.moveItem(atPath: url.path, toPath: tempURL.path)

      } catch {
        print(error.localizedDescription)

      }
    }
    if isSecuredURL {
      url.stopAccessingSecurityScopedResource()
    }
  }

  func beginDownloadingFile() {
    DispatchQueue.global(qos: .userInitiated).async {
      let url = URL(fileURLWithPath: self.remoteFilePath)
      let isSecuredURL = url.startAccessingSecurityScopedResource() == true
      let coordinator = NSFileCoordinator()
      var error: NSError? = nil
      coordinator.coordinate(
        readingItemAt: URL(string: self.remoteFilePath)!, options: [], error: &error
      ) { (url2) -> Void in

        print("Download started for \(self.localFileURL)")
        //            DispatchQueue.global(qos: .userInitiated).async {
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(
          configuration: configuration,
          delegate: DownloaderDelegate(
            bookID: self.bookID, progress: self.$progress, localFileURL: self.localFileURL),
          delegateQueue: operationQueue)
        NSLog(url2.path)
        guard let url = URL(string: self.remoteFilePath) else {
          NSLog("URL Not valid")
          return
        }
        //            https://stackoverflow.com/questions/26622062/how-do-i-tell-ios-to-download-a-file-from-icloud-drive-and-get-progress-feedback
        //            let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        let downloadTask = urlSession.downloadTask(with: url2)
        downloadTask.resume()
      }
    }
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

    func urlSession(
      _ session: URLSession, downloadTask: URLSessionDownloadTask,
      didFinishDownloadingTo location: URL
    ) {
      NSLog("Finished download!")
      print("Moving file from: \(location)")
      print("to: \(self.localFileURL)")

      try! FileManager.default.moveItem(at: location, to: self.localFileURL)

      let userInfo = ["bookID": bookID, "localURL": localFileURL.path] as [String: Any]
      NotificationCenter.default.post(name: .downloadComplete, object: nil, userInfo: userInfo)
    }

    func urlSession(
      _ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,
      totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64
    ) {

      let percentage = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
      self.progress.wrappedValue = percentage

      // TODO: Replace with struct
      let userInfo =
        ["bookID": bookID, "percentage": percentage, "localURL": localFileURL.path] as [String: Any]
      NotificationCenter.default.post(
        name: .downloadProgressUpdate, object: nil, userInfo: userInfo)
    }
  }
}
