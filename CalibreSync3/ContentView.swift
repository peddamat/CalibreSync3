//
//  ContentView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB
import QGrid
import SwiftUI
import Combine
import KingfisherSwiftUI

// The shared database queue
var dbQueue: DatabaseQueue?

struct ContentView: View {
    @EnvironmentObject var settingStore: SettingStore
    @State private var showSettings = false
    var calibrePath: String

    func getDBqueue() -> DatabaseQueue {
        
        if dbQueue != nil {
            return dbQueue!
        }
        
        let calibreDB = CalibreDB(settingStore: settingStore)
        dbQueue = calibreDB.load()
        return dbQueue!
    }
    
    func getBooks() -> [Book] {
        var books: [Book]?
        
        let calibreDB = CalibreDB(settingStore: settingStore)
        let dbQueue = calibreDB.load()

        do {
            try dbQueue.read { db -> [Book] in
                books = try Book.limit(100).fetchAll(db)
                return books!
            }
        } catch {
            print("Error: Unable to get books")
        }
        return books!
    }
    
    var profileButton: some View {
        Button(action: { self.showSettings.toggle() }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .accessibility(label: Text("User Profile"))
                .padding()
        }
    }
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    QGrid(getBooks(), columns: 3) { book in
//                        GridCell(book: book, calibreLibraryPath: self.calibrePath, dbQueue: self.getDBqueue())

                        ZStack {
//                            Image("cover")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 150, height: 150)
            
//                            ImageStubView(withURL: "/private/var/mobile/Library/LiveFiles/com.apple.filesystems.smbclientd/Jg110QPublic/Old/Ebook%20Library/Atul%20S.%20Khot/Scala%20Functional%20Programming%20Patter%20(411)/cover.jpg", withPath: self.calibrePath, withDB: self.getDBqueue())
                            
//                            ImageView(withURL: "file:///private/var/mobile/Library/LiveFiles/com.apple.filesystems.smbclientd/Jg110QPublic/Old/Ebook Library/Atul S. Khot/Scala Functional Programming Patter (411)/cover.jpg".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
//                            .padding([.horizontal, .top], 2.0)

                            ImageView(withURL: URL(fileURLWithPath: self.calibrePath + "/" + book.path + "/cover.jpg").absoluteString)
                                .padding([.horizontal, .top], 2.0)

                            Text(book.title)
                        }
                    }
                }
                .navigationBarTitle("CalibreSync")
                .navigationBarItems(trailing: profileButton)
                .sheet(isPresented: $showSettings) {
                    SettingsView().environmentObject(self.settingStore)
                }
            }
        }
    }
}

struct ImageStubView: View {
//    @State var image:UIImage = UIImage()
    
    init(withURL url:String, withPath: String, withDB: DatabaseQueue) {
        print(url)
        let h = withDB
    }
    
    var body: some View {
//        VStack {
            Image("cover")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:150, height:150)
            .padding(10)
//        }
//        }.onReceive(imageLoader.didChange) { data in
//            self.image = UIImage(data: data) ?? UIImage()
//        }
    }
}

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString:String) {
        
        guard let url = URL(string: urlString) else {
            print("Punt! \(urlString)")
            return
        }
        
//        DispatchQueue.global(qos: .userInitiated).async {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.data = data
                }
            }
            task.resume()
//        }
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()
    
    init(withURL url:String) {
        imageLoader = ImageLoader(urlString:url)
//        print("Fuck: \(url)")
    }
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:150, height:150)
            .padding(10)
        }.onReceive(imageLoader.didChange) { data in
            self.image = UIImage(data: data) ?? UIImage()
        }
    }
}



struct GridCell: View {
    var book: Book
    var calibreLibraryPath: String
    var dbQueue: DatabaseQueue

    var body: some View {
        VStack() {
//            NavigationLink(destination: BooksDetail(book: book, calibrePath: calibreLibraryPath, dbQueue: dbQueue)) {
//                Image("cover")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 150, height: 150)
                
            ImageStubView(withURL: URL(fileURLWithPath: calibreLibraryPath + "/" + book.path + "/cover.jpg").absoluteString, withPath: calibreLibraryPath, withDB: dbQueue)
            
//                ImageView(withURL: URL(fileURLWithPath: calibreLibraryPath + "/" + book.path + "/cover.jpg").absoluteString)
//                    .padding([.horizontal, .top], 2.0)
                
//                KFImage(URL(fileURLWithPath: calibreLibraryPath + "/" + book.path + "/cover.jpg"))
//                .onSuccess { r in
//                    print("suc: \(r)")
//                }
//                .onFailure { e in
//                    print("err: \(e)")
//                }
//                .placeholder {
//                    Image(systemName: "arrow.2.circlepath.circle")
//                        .font(.largeTitle)
//                }
//                .resizable()
//                .frame(width: 150, height: 150)
//                .cornerRadius(20)
//                .shadow(radius: 5)
                
    //            Text(book.title)
//            }
//            .buttonStyle(PlainButtonStyle())
        }
    }
}
    

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environmentObject(SettingStore())
//    }
//}
