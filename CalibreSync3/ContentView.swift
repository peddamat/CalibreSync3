//
//  ContentView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI
import Combine
import GRDB
import Grid

struct ContentView: View  {
    @EnvironmentObject var settingStore: SettingStore
    @ObservedObject var bookCache = BookCache()

    // Modal overlay toggles
    @State private var showSettings = false
//    @State private var showShareSheet = false
    @State private var showDocumentSheet = false

    // Book cover grid styling options
    @State var style = ModularGridStyle(columns: .min(100), rows: .min(100*(4/3)))
    
    private var calibreDB: CalibreDB {
        return try! CalibreDB(settingStore: settingStore)
    }
    
    private var calibrePath: URL {
        return try! settingStore.getCalibreURL()
    }
    
    let dummyCover = URL(fileURLWithPath: "/private/var/mobile/Library/LiveFiles/com.apple.filesystems.smbclientd/zAOBnwPublic/Old/Ebook Library/Harvard Business Review/HBR's 10 Must Reads for New Manager (106)/cover.jpg")
    
    var profileButton: some View {
        Button(action: { self.showSettings.toggle() }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .accessibility(label: Text("User Profile"))
                .padding()
        }
    }
    
    var shareButton: some View {
        Button(action: {
//            self.showShareSheet.toggle()
            self.bookCache.removeBook()
        }) {
            Image(systemName: "square.and.arrow.up")
                .imageScale(.large)
                .accessibility(label: Text("Share"))
                .padding()
        }
    }
    
    var docShareButton: some View {
        Button(action: { self.showDocumentSheet.toggle() }) {
            Image(systemName: "square.and.arrow.up")
                .imageScale(.large)
                .accessibility(label: Text("Share"))
                .padding()
        }
    }

    
    var body2: some View {
        NavigationView {
            
            Grid(bookCache.books) { book in
                NavigationLink(destination: BookDetail(book: book, calibreDB: self.calibreDB)) {

//                    BookCover(title: "\(book.title)", fetchURL: self.calibreDB.getCalibrePath().appendingPathComponent("/").appendingPathComponent(book.path).appendingPathComponent("cover.jpg"))

//                    BookCover(title: "\(book.title)", fetchURL: URL(fileURLWithPath: self.calibrePath.path + "/" + book.path + "/cover.jpg"))
                    
                    BookCover(title: "\(book.title)", fetchURL: self.dummyCover)

                    
//                    BookCover(title: "\(book.title)", fetchURL: URL(string:"https://picsum.photos/120/140")!)

                    
                    // TODO: Why do fetches from a "https://" URL scheme happen so much quicker?
                    // Card(title: "\(book.title)", fetchURL: URL(string:"https://picsum.photos/120/140")!)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .gridStyle(
                self.style
            )

            .navigationBarTitle("CalibreSync")
            .navigationBarItems(trailing: HStack {
                profileButton
                 shareButton
            })
            
            .sheet(isPresented: $showSettings) {
                SettingsView().environmentObject(self.settingStore)
            }
        }
        .onAppear {
            self.bookCache.getBooks(calibreDB: self.calibreDB, limit:99)
        }
//            .sheet(isPresented: $showShareSheet) {
//                ShareSheet(activityItems: ["Hello World"])
//            }
    }
    
    var body: some View {
        NavigationView {
            Grid(bookCache.books) { book in
                NavigationLink(destination: BookDetail(book: book, calibreDB: self.calibreDB)) {

//                    BookCover(title: "\(book.title)", fetchURL: self.dummyCover)
                    
                    BookCover(title: "\(book.title)", fetchURL: URL(fileURLWithPath: self.calibrePath.path + "/" + book.path + "/cover.jpg"))

//                    BookCover(title: "\(book.title)", fetchURL: self.calibreDB.getCalibrePath().appendingPathComponent("/").appendingPathComponent(book.path).appendingPathComponent("cover.jpg"))

                }.buttonStyle(PlainButtonStyle())
            }
            .gridStyle(self.style)
            .onAppear {
                self.bookCache.getBooks(calibreDB: self.calibreDB, limit:99)
            }
                
            .navigationBarTitle("CalibreSync", displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: { self.showSettings = true }) {
                    Image(systemName: "gear")
                }
            )
        }

        .navigationViewStyle(
            StackNavigationViewStyle()
        )

    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environmentObject(SettingStore())
//    }
//}
