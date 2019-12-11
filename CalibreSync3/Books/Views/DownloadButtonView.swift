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
    var fileURL: String
    @State private var progress: Float = 0.0
    @State private var progress2: Float = 0.0
    
    var body: some View {
        Button(action: {
            let downloader = Downloader(bookID: self.bookID, urlString: self.fileURL, progress: self.$progress)
            downloader.beginDownloadingFile()
        }) {            
            ZStack {
                Rectangle()
                    .fill(Color.gray)
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
                Text(String(progress2))
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .bold()
            }
        }.onAppear {
            NotificationCenter.default.addObserver(forName: .downloadProgressUpdate, object: nil, queue: .main) { (notification) in
                self.progress2 = 0
                if let data = notification.userInfo as? [String: Any]
                {
                    if data["bookID"]! as! Int == self.bookID {
                        self.progress2 = data["percentage"]! as! Float
                    }
                }
            }
        }
    }
    
}

struct DownloadButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadButtonView(bookID: 1, format: "PDF", fileURL: "/")
    }
}
