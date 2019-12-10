//
//  DownloadButton.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/10/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct DownloadButtonView: View {
    var format: String
    var fileURL: String
    @State private var progress: Float = 0.0
    
    
    var body: some View {
        Button(action: {
            let downloader = Downloader(urlString: self.fileURL, progress: self.$progress)
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
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: CGFloat(50*progress))
                                .cornerRadius(10)
                        }
                        ,alignment: .bottomTrailing)
                Text(format)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .bold()
            }
        }
    }
}

struct DownloadButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadButtonView(format: "PDF", fileURL: "/")
    }
}
