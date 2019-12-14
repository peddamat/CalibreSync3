//
//  LibraryView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/13/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI
import Fuzzy

struct LibraryView: View  {
    @EnvironmentObject var settingStore: SettingStore
//    @State var bookCache = BookCache()
    var bookCache: BookCache
    @State private var books: [DiskBook] = []
    @ObservedObject var model = MyModel()
    @State private var scrollOffset = 33
            
    // Book cover grid styling options
    @State var style = ModularGridStyle(columns: .min(BOOK_WIDTH), rows: .min(BOOK_HEIGHT))
    //    @State var style = ModularGridStyle(columns: .min(100), rows: .min(100))
    //    @State var style = StaggeredGridStyle(tracks: .min(100), axis: .vertical, spacing: 1, padding: .init(top: 1, leading: 1, bottom: 1, trailing: 1))
    
    @State var calibreDB: CalibreDB?
    private func getCalibreDB() -> CalibreDB {
        guard self.calibreDB != nil else {
            self.calibreDB = try! CalibreDB(settingStore: settingStore)
            return self.calibreDB!
        }
        return self.calibreDB!
    }
        
    let dummyCover = URL(fileURLWithPath: "/private/var/mobile/Library/LiveFiles/com.apple.filesystems.smbclientd/zAOBnwPublic/Old/Ebook Library/Harvard Business Review/HBR's 10 Must Reads for New Manager (106)/cover.jpg")
    
    var body: some View {
        ZStack {
            Color.init(red: 244/255.0, green: 236/255.0, blue: 230/255.0)
            .edgesIgnoringSafeArea(.all)
            VStack {
                // TODO: Enable sorting
                Grid(self.books.prefix(scrollOffset).filter { return search(needle: self.settingStore.searchString, haystack:$0.title) }) { book in
        //        Grid(self.books) { book in
                    NavigationLink(destination: BookDetail(book: book, bookCache: self.bookCache, calibreDB: self.getCalibreDB()).environmentObject(self.settingStore)) {
                        
        //                BookCover(title: (book.title), fetchURL: self.dummyCover)
                        
                        BookCover(title: (book.title), fetchURL: self.bookCache.getCover(forBook: book))
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
                .gridStyle(self.style)
                .onAppear {
                    self.bookCache.getBooks(calibreDB: self.getCalibreDB())
                    
                    NotificationCenter.default.addObserver(forName: .refreshBookCache, object: nil, queue: .main) { (notification) in
                        self.bookCache.getBooks(calibreDB: self.getCalibreDB())
                    }
                    
                    NotificationCenter.default.addObserver(forName: .loadMoreBookCache, object: nil, queue: .main) { (notification) in
                        self.scrollOffset += self.settingStore.itemsPerScreen
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
