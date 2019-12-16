//
//  LibraryView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/13/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI
import Fuzzy
import Fuse
//import WaterfallGrid

struct LibraryView: View  {
    var bookCache: BookCache

    @ObservedObject var store = Store.shared
    @ObservedObject var model = MyModel()

    @State private var books: [DiskBook] = []
    @State private var scrollOffset = 55
            
    // Book cover grid styling options
    @State var style = ModularGridStyle(columns: .min(BOOK_WIDTH), rows: .min(BOOK_HEIGHT))
    
    @State var calibreDB: CalibreDB?
    private func getCalibreDB() -> CalibreDB {
        guard self.calibreDB != nil else {
            self.calibreDB = try! CalibreDB(store: store)
            return self.calibreDB!
        }
        return self.calibreDB!
    }
        
    var body: some View {
        ZStack {
            Color.init(red: 244/255.0, green: 236/255.0, blue: 230/255.0)
            .edgesIgnoringSafeArea(.all)
            VStack {
                // TODO: Enable sorting
                Grid(self.books.filter({ return search(needle: self.store.searchString, haystack:$0.title) }).prefix(scrollOffset)) { book in
//                WaterfallGrid(self.books.filter({ return search(needle: self.store.searchString, haystack:$0.title) }).prefix(scrollOffset)) { book in
                    
                    NavigationLink(destination: BookDetail(book: book, bookCache: self.bookCache, calibreDB: self.getCalibreDB()).environmentObject(self.store)) {
                                                
                        BookCover(title: book.title, downloaded: book.downloaded ?? false, fetchURL: self.bookCache.getCover(forBook: book))
                            .contextMenu {
                                Button(action: {
                                    // delete the selected restaurant
                                }) {
                                    HStack {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                }
                        }
                        
        //                BookCover(title: "1", fetchURL: URL(string:"https://picsum.photos/120/140")!)
        //
        //                Card(title: book.title, fetchURL: self.calibreDB.getCalibrePath().appendingPathComponent("/").appendingPathComponent(book.path).appendingPathComponent("cover.jpg"))
                        
                    }.buttonStyle(PlainButtonStyle())
                }
//                .gridStyle(
//                  columnsInPortrait: 3,
//                  columnsInLandscape: 6
//                )
                .gridStyle(self.style)
                .onAppear {
                    self.bookCache.getBooks(calibreDB: self.getCalibreDB())
                    
                    NotificationCenter.default.addObserver(forName: .refreshBookCache, object: nil, queue: .main) { (notification) in
                        self.bookCache.getBooks(calibreDB: self.getCalibreDB())
                        self.scrollOffset = 55
                    }
                    
                    NotificationCenter.default.addObserver(forName: .loadMoreBookCache, object: nil, queue: .main) { (notification) in
                        self.scrollOffset += self.store.itemsPerScreen
                    }
                }
                .onReceive(self.bookCache.didChange) { books in
                    self.books = books
                    NSLog("Ping")
                }
        }
        }
        
    }
}

//struct LibraryView_Previews: PreviewProvider {
//    static var previews: some View {
//        LibraryView()
//    }
//}
