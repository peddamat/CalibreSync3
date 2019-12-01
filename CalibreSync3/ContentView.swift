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

// The shared database queue
var dbQueue: DatabaseQueue!

struct ContentView: View {
    @EnvironmentObject var settingStore: SettingStore
    @State private var showSettings = false

    func getBooks() -> [Book] {
        var books: [Book]?
        
        let calibreDB = CalibreDB(settingStore: settingStore)
        let dbQueue = calibreDB.load()

        do {
            try dbQueue.read { db -> [Book] in
                books = try Book.fetchAll(db)
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
        NavigationView {
            VStack {
//                Text(settingStore.getCalibrePath())
//                ForEach(getBooks(), id: \.self) { book in
//                    Text(book.path)
//                        .padding()
//                }
                QGrid(getBooks(), columns: 3) {
                    GridCell(book: $0, calibreLibraryPath: self.settingStore.getCalibrePath())
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

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()
    
    init(withURL url:String) {
        imageLoader = ImageLoader(urlString:url)
        print(url)
    }
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:100, height:100)
        }.onReceive(imageLoader.didChange) { data in
            self.image = UIImage(data: data) ?? UIImage()
        }
    }
}

struct GridCell: View {
    var book: Book
    var calibreLibraryPath: String

    var body: some View {
        VStack() {
            ImageView(withURL: URL(fileURLWithPath: calibreLibraryPath + "/" + book.path + "/cover.jpg").absoluteString)
                .padding([.horizontal, .top], 2.0)
            Text(book.title)
        }
    }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SettingStore())
    }
}
