//
//  BooksDetail.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/2/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB
import SwiftUI

struct BookDetail: View {
    var book: DiskBook
    var bookCache: BookCache
    var calibreDB: CalibreDB
    var dbQueue: DatabaseQueue {
        calibreDB.getDBqueue()
    }
    @EnvironmentObject var settingStore: SettingStore
    
    @State private var showingSheet = false
    @State private var showDocumentSheet = false
    @State private var bookPath:URL?
    
    @State private var progress:Float = 0.0
    
    func getActions() -> [(String, String)]? {
        var buttons = [(String, String)]()
        
        do {
            try dbQueue.read { db -> [(String, String)] in
                let formats = try DiskBookFormat
                    .filter(Column("book") == book.id)
                    .fetchAll(db)
                
                for format in formats {
                    let bookPath = "file://" + self.bookCache.getBookFileURL(settingStore: self.settingStore, book: self.book, format: format).path
                    
                    let button = (format.format, bookPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    buttons.append(button)
                }
                return buttons
            }
        } catch {
            NSLog("Error: Unable to get books")
        }
        return buttons
    }
    
    var body: some View {
        
        ZStack {
            ScrollView {
                VStack {
                    BookHeader(book: book, bookCache: bookCache)
                    Separator()
                    
                    HStack(spacing:1) {
                        Spacer()
                        
                        ForEach(getActions()!, id:\.self.0) { info in
                            DownloadButtonView(format: info.0, fileURL: info.1)

                        }
                        Spacer()
                    }
                
                    //                TagList()
                    BookSummary(book: book, dbQueue: dbQueue)
                    Spacer()
                }
            }
            .padding(10)
//            .sheet(isPresented: $showDocumentSheet) {
//                FilePresenterUIView(file: self.bookPath!, onDismiss: { self.showDocumentSheet = false })
//                .opacity(0)
//            }
            if(showDocumentSheet) {
                FilePresenterUIView(file: self.bookPath!, onDismiss: { self.showDocumentSheet = false })
            }
        }
            
    }

}

struct BookHeader: View {
    @EnvironmentObject var settingStore: SettingStore
    
    var book: DiskBook
    var bookCache: BookCache
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            BookCover(title: (book.title.trimmingCharacters(in: .whitespacesAndNewlines)), fetchURL: self.bookCache.getBookCoverURL(settingStore: self.settingStore, book: book))
            
            VStack(alignment: .leading, spacing:5) {
                Text(book.title.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.system(size:16, design:.rounded))
                    .fontWeight(.black)
                
                Text(book.author_sort.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }
}

struct BookSummary: View {
    var book: DiskBook
    var dbQueue: DatabaseQueue
    @State var comments: [DiskBookComment]?
    
    func getComments() -> [DiskBookComment] {
        do {
            return try dbQueue.read { db in
                //                try book.comments.fetchAll(db)
                try DiskBookComment
                    .filter(Column("book") == book.id)
                    .fetchAll(db)
            }
        } catch {
            return []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("SUMMARY")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .padding(.bottom, 5)
                Spacer()
            }
            ForEach(getComments()) { comment in
                Text(comment.text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
            }
        }
    .padding(10)
    }
}

struct Tag: View {
    var name: String
    
    var body: some View {
        Text(name)
            .foregroundColor(.white)
            .padding(5)
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct TagList: View {
    var body: some View {
        HStack(spacing: 5) {
            Tag(name: "Swift")
            Tag(name: "Development")
            Tag(name: "Coding")
        }
    }
}

struct Separator: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color(red: 240/255, green: 240/255, blue: 240/255))
            .padding(.horizontal)
    }
}
