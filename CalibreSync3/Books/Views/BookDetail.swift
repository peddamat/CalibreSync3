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
    var book: Book
    var bookCache: BookCache
    var calibreDB: CalibreDB
    var dbQueue: DatabaseQueue {
        calibreDB.getDBqueue()
    }
    @EnvironmentObject var settingStore: SettingStore
    
    @State private var showingSheet = false
    @State private var showDocumentSheet = false
    @State private var bookPath:URL?
    
    func getActions() -> [PopSheet.Button]? {
        var buttons = [PopSheet.Button]()
        
        do {
            try dbQueue.read { db -> [PopSheet.Button] in
                let formats = try BookFormat
                    .filter(Column("book") == book.id)
                    .fetchAll(db)
                
                for format in formats {
                    let button = PopSheet.Button(kind: .default, label: Text(format.format), action: {
                        self.bookPath = self.bookCache.getBookFileURL(settingStore: self.settingStore, book: self.book, format: format)
                        NSLog(self.bookPath!.path)
                        self.showDocumentSheet.toggle()
                    })
                    buttons.append(button)
                }
                
                // Finally, always add the close button
                buttons.append(PopSheet.Button(kind: .cancel, label: Text("Cancel"), action: {}))
                
                return buttons
            }
        } catch {
            NSLog("Error: Unable to get books")
        }
        return buttons
    }
    
    var body: some View {
        ScrollView {
            VStack {
                BookHeader(book: book)
                Separator()
                
                Button(action: {
                    self.showingSheet = true
                }) {
                    Text("Download")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(red: 0/255, green: 212/255, blue: 255/255))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .popSheet(isPresented: $showingSheet, content: {
                    PopSheet(title: Text("Select a format"), buttons: self.getActions()!)
                })
                    
//                TagList()
                BookSummary(book: book, dbQueue: dbQueue)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showDocumentSheet) {
            FilePresenterUIView(file: self.bookPath!, onDismiss: { self.showDocumentSheet = false })
        }
    }
}

struct BookHeader: View {
    @EnvironmentObject var settingStore: SettingStore
    
    var book: Book
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            //            ImageView(withURL: self.settingStore.calibreRemoteLibraryURL!.appendingPathComponent("/").appendingPathComponent(book.path).appendingPathComponent("cover.jpg"))
            //                .resizable()
            //                .scaledToFit()
            //                .frame(width:110)
            
            VStack(alignment: .leading, spacing:5) {
                Text(book.title)
                    .font(.system(size:16, design:.rounded))
                    .fontWeight(.black)
                
                Text(book.author_sort)
            }
        }
    }
}

struct BookSummary: View {
    var book: Book
    var dbQueue: DatabaseQueue
    @State var comments: [BookComment]?
    
    func getComments() -> [BookComment] {
        do {
            return try dbQueue.read { db in
                //                try book.comments.fetchAll(db)
                try BookComment
                    .filter(Column("book") == book.id)
                    .fetchAll(db)
            }
        } catch {
            return []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("SUMMARY")
            ForEach(getComments()) { comment in
                Text(comment.text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
            }
        }
        .padding(.top, 10)
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
