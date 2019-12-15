//
//  DownloadButton.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/10/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct DownloadButtonView: View {
    var bookID: Int
    var format: String
    var fileLocalURL: URL
    var fileRemoteURL: String
    var isCached: Bool
    
    @State private var progress: Float = 0.0
    @State private var progress2: Float = 0.0
    
    var body: some View {
        Button(action: {
            if self.isCached || self.progress2 == 1 {
                let userInfo = ["bookPath": self.fileLocalURL.path]
                NotificationCenter.default.post(name: .openBook, object: nil, userInfo: userInfo)
            } else {
                let downloader = Downloader(bookID: self.bookID,
                                            localFileURL: self.fileLocalURL,
                                            remoteFilePath: self.fileRemoteURL,
                                            progress: self.$progress)
                downloader.beginDownloadingFile()
            }
        }) {            
            ZStack {
                Rectangle()
                    .fill(isCached ? Color(red: 0/255, green: 212/255, blue: 255/255) : Color.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .cornerRadius(10)
                    .overlay(
                        VStack {
                            Rectangle()
                                .fill(Color(red: 0/255, green: 212/255, blue: 255/255))
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: CGFloat(50*progress2))
                                .cornerRadius(10)
                        }
                        ,alignment: .bottomTrailing)
                VStack {
                    Text((isCached || (progress2 == 1)) ? "Open \(format)" : "Get \(format)")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                        .bold()
                    // TODO: Jesus christ...
                    if !isCached {
                        if ((progress2 > 0) && (progress2 < 1)) {
                            Text(String(format: "%.2f%%", progress2*100))
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }.onAppear {
            NotificationCenter.default.addObserver(forName: .downloadProgressUpdate, object: nil, queue: .main) { (notification) in
//                self.progress2 = 0
                if let data = notification.userInfo as? [String: Any]
                {
                    if (data["bookID"]! as! Int == self.bookID) &&
                        (data["localURL"]! as! String == self.fileLocalURL.path){
                        self.progress2 = data["percentage"]! as! Float
                    }
                }
            }
        }
    }
    
}

struct DownloadButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadButtonView(bookID: 1, format: "PDF", fileLocalURL: URL(string: "/")!, fileRemoteURL: "/", isCached: true)
    }
}