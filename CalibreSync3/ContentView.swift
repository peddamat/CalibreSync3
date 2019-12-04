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
//import Grid
import Fuzzy

struct ContentView2: View {
    @EnvironmentObject var settingStore: SettingStore

    @ObservedObject var model = MyModel()
    @State private var alternate: Bool = true
    
    let array = Array<String>(repeating: "Hello", count: 100)
    let transaction = Transaction(animation: .easeInOut(duration: 2.0))
    
    var body: some View {
        
        return VStack(spacing: 0) {
            HeaderView(title: "Dog Roulette")
            
            RefreshableScrollView(height: 70, refreshing: self.$model.loading) {
                
                Text("Hi").padding(30).background(Color(UIColor.systemBackground))
                
            }.background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    struct HeaderView: View {
        var title = ""
        
        var body: some View {
            VStack {
                Color(UIColor.black).frame(height: 30).overlay(Text(self.title))
                Color(white: 0.5).frame(height: 3)
            }
        }
    }
}

class MyModel: ObservableObject {
    @Published var loading: Bool = false {
        didSet {
            if oldValue == false && loading == true {
//                self.load()
            }
        }
    }
    
    var idx = 0
    
    func load() {
        // Simulate async task
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.loading = false
        }
    }
}


struct ContentView: View {
    @EnvironmentObject var settingStore: SettingStore
    @State var bookCache = BookCache()

    
    // Modal overlay toggles
    @State private var showSettings = false
    @State private var showShareSheet = false
    @State private var showDocumentSheet = false
    @State var showMenu = false
    
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
    
    var menuButton: some View {
        Button(action: {
            withAnimation {
                self.showMenu.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
                .imageScale(.large)
        }
    }

    var body: some View {
        let drag = DragGesture()
            .onEnded {
                if $0.translation.width > 100 {
                    withAnimation {
                        self.showMenu = true
                    }
                }
                if $0.translation.width < -100 {
                    withAnimation {
                        self.showMenu = false
                    }
                }
        }
        
        return NavigationView {
//            MainView(bookCache: self.$bookCache).environmentObject(self.settingStore)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    MainView(bookCache: self.$bookCache).environmentObject(self.settingStore)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: self.showMenu ? geometry.size.width/2.0 : 0)
                        .disabled(self.showMenu ? true : false)
                    .gesture(drag)
                    if self.showMenu {
                        SideMenuView()
                            .frame(width: geometry.size.width/2)
                            .transition(.move(edge: .leading))
                    }
                }
                
            }
            .navigationBarTitle("Side Menu", displayMode: .inline)
            .navigationBarItems(leading: (
                Button(action: {
                    withAnimation {
                        self.showMenu.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                }
            ))
                
            .navigationBarTitle("CalibreSync", displayMode: .inline)
                .navigationBarItems(leading: menuButton, trailing: HStack {
                profileButton
                shareButton
            })
        }
        .navigationViewStyle(
            StackNavigationViewStyle()
        )
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(self.settingStore)
        }
    }
}

struct MainView: View  {
    @EnvironmentObject var settingStore: SettingStore
//    @State var bookCache = BookCache()
    @Binding var bookCache: BookCache
    @State private var books: [Book] = []
        
    // Book cover grid styling options
    @State var style = ModularGridStyle(columns: .min(BOOK_WIDTH), rows: .min(BOOK_HEIGHT))
    //    @State var style = ModularGridStyle(columns: .min(100), rows: .min(100))
    //    @State var style = StaggeredGridStyle(tracks: .min(100), axis: .vertical, spacing: 1, padding: .init(top: 1, leading: 1, bottom: 1, trailing: 1))
    
    private var calibreDB: CalibreDB {
        return try! CalibreDB(settingStore: settingStore)
    }
    
    private var calibrePath: URL {
        return try! settingStore.getCalibreURL()
    }
    
    let dummyCover = URL(fileURLWithPath: "/private/var/mobile/Library/LiveFiles/com.apple.filesystems.smbclientd/zAOBnwPublic/Old/Ebook Library/Harvard Business Review/HBR's 10 Must Reads for New Manager (106)/cover.jpg")
    
    var body: some View {
        Grid(self.books.filter { return search(needle: "electr", haystack:$0.title) }) { book in
            NavigationLink(destination: BookDetail(book: book, calibreDB: self.calibreDB)) {
                
//                BookCover(title: (book.title), fetchURL: self.dummyCover)
                
                BookCover(title: (book.title), fetchURL: URL(fileURLWithPath: self.calibrePath.path + "/" + book.path + "/cover.jpg"))
                
//                BookCover(title: "1", fetchURL: URL(string:"https://picsum.photos/120/140")!)
//
//                Card(title: book.title, fetchURL: self.calibreDB.getCalibrePath().appendingPathComponent("/").appendingPathComponent(book.path).appendingPathComponent("cover.jpg"))
                
            }.buttonStyle(PlainButtonStyle())
        }
        .gridStyle(self.style)
        .onAppear {
            self.bookCache.getBooks(calibreDB: self.calibreDB, limit:9)
        }
        .onReceive(self.bookCache.didChange) { books in
            self.books = books
            NSLog("Ping")
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environmentObject(SettingStore())
//    }
//}
