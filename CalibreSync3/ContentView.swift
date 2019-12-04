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

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var settingStore: SettingStore

    let array = ["Peter", "Paul", "Mary", "Anna-Lena", "George", "John", "Greg", "Thomas", "Robert", "Bernie", "Mike", "Benno", "Hugo", "Miles", "Michael", "Mikel", "Tim", "Tom", "Lottie", "Lorrie", "Barbara"]
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false


    var body: some View {

        // Search view
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")

                TextField("search", text: self.$searchText, onEditingChanged: { isEditing in
                    self.showCancelButton = true
                }, onCommit: {
                    print("onCommit")
                    self.settingStore.searchString = self.searchText
                }).foregroundColor(.primary)

                Button(action: {
                    self.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill").opacity(self.searchText == "" ? 0.0 : 1.0)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)

            if showCancelButton  {
                Button("Cancel") {
                        UIApplication.shared.endEditing(true) // this must be placed before the other commands here
                        self.searchText = ""
                        self.showCancelButton = false
                }
                .foregroundColor(Color(.systemBlue))
            }
        }
        .padding(.horizontal)
        .frame(width:UIScreen.main.bounds.width, height: nil)
        .navigationBarHidden(showCancelButton) // .animation(.default) // animation does not work properly

//            List {
//                // Filtered list of names
//                ForEach(array.filter{$0.hasPrefix(searchText) || searchText == ""}, id:\.self) {
//                    searchText in Text(searchText)
//                }
//            }
//            .navigationBarTitle(Text("Search"))
        .resignKeyboardOnDragGesture()
    
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
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
//                    .gesture(drag)
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
        Grid(self.books.filter { return search(needle: self.settingStore.searchString, haystack:$0.title) }) { book in
//        Grid(self.books) { book in
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
            self.bookCache.getBooks(calibreDB: self.calibreDB, limit:40)
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
