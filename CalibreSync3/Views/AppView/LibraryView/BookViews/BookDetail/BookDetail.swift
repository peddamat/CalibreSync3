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
  @ObservedObject var store = Store.shared

  var book: DiskBook
  var bookCache: BookCache
  var calibreDB: CalibreDB
  var dbQueue: DatabaseQueue {
    calibreDB.dbQueue
  }

  @State private var showingSheet = false
  @State private var showDocumentSheet = false
  @State private var bookPath: URL?
  @State private var progress: Float = 0.0

  // TODO: Replace this with a struct
  func getActions() -> [(Int, String, URL, String, Bool)]? {
    var buttons = [(Int, String, URL, String, Bool)]()

    do {
      try dbQueue.read { db -> [(Int, String, URL, String, Bool)] in
        let formats =
          try DiskBookFormat
          .filter(Column("book") == book.id)
          .fetchAll(db)

        for format in formats {
          let bookLocalPath = self.bookCache.getLocalFile(forBook: self.book, withFormat: format)
          let bookRemotePath =
            "file://" + self.bookCache.getRemoteFile(forBook: self.book, withFormat: format).path
          let isCached = self.bookCache.checkCached(forBook: self.book, withFormat: format)

          let button = (
            Int(book.id),
            format.format,
            bookLocalPath,
            bookRemotePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            isCached
          )
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

          HStack(spacing: 1) {
            Spacer()

            // TODO: id on format ID, not the path...
            ForEach(getActions()!, id: \.self.2) { info in
              DownloadButtonView(
                bookID: info.0, format: info.1, fileLocalURL: info.2, fileRemoteURL: info.3,
                isCached: info.4)

            }
            Spacer()
          }

          //                TagList()
          BookSummary(book: book, dbQueue: dbQueue)
          Spacer()
        }
      }
      .padding(10)
      .onAppear {
        NotificationCenter.default.addObserver(forName: .openBook, object: nil, queue: .main) {
          (notification) in

          NSLog("Received open book notification")
          if let userInfo = notification.userInfo {
            self.bookPath = URL(fileURLWithPath: (userInfo["bookPath"] as? String)!)
          }

          self.showDocumentSheet = true
        }
      }
      if showDocumentSheet {
        FilePresenterUIView(file: self.bookPath!, onDismiss: { self.showDocumentSheet = false })
      }
    }
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
      .background(Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255))
      .padding(.horizontal)
  }
}
