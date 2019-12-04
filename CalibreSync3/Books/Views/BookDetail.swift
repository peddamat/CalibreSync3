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
    var calibreDB: CalibreDB
    var dbQueue: DatabaseQueue {
        calibreDB.getDBqueue()
    }
    
    @State private var showingSheet = false
    @State private var showDocumentSheet = false
    @State private var bookPath:String = ""

    func getActions() -> [ActionSheet.Button]? {
        var buttons = [ActionSheet.Button]()
        
        do {
            try dbQueue.read { db -> [ActionSheet.Button] in
                let formats = try BookFormat
                    .filter(Column("book") == book.id)
                    .fetchAll(db)
                
                for format in formats {
                    if format.format == "PDF" {
                        buttons.append(
                            .default(Text("PDF"), action: {
                                let tempPath = "file://" + self.calibreDB.getCalibrePath().path + "/" + self.book.path + "/" + format.name + ".pdf"
                                self.bookPath = tempPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                self.showDocumentSheet.toggle()
                            }))
                    }
                    else if format.format == "EPUB" {
                        buttons.append(
                            .default(Text("EPUB"), action: {
                                let tempPath = "file://" + self.calibreDB.getCalibrePath().path + "/" + self.book.path + "/" + format.name + ".epub"
                                self.bookPath = tempPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                self.showDocumentSheet.toggle()
                            }))
                    }
                }
                
                // Finally, always add the close button
                buttons.append(.default(Text("Dismiss")))
                
                return buttons
            }
        } catch {
            print("Error: Unable to get books")
        }
        return buttons
    }
    
    var body: some View {
        ScrollView {
            VStack {
                BookHeader(book: book, calibrePath: calibreDB.getCalibrePath())
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
//                TagList()
                BookSummary(book: book, dbQueue: dbQueue)
                Spacer()
            }
        }
        .actionSheet(isPresented: $showingSheet) {
            ActionSheet(title: Text("Select a format"), message: Text("Depending on what other apps you have installed"), buttons: getActions()!)
        }
        .sheet(isPresented: $showDocumentSheet) {
            FilePresenterUIView(file: URL(string: self.bookPath)!, onDismiss: { self.showDocumentSheet.toggle() })
        }
    }
}

struct BookHeader: View {
    var book: Book
    var calibrePath: URL
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ImageView(withURL: calibrePath.appendingPathComponent("/").appendingPathComponent(book.path).appendingPathComponent("cover.jpg"))
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