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
import Macduff

struct ContentView: View  {
    @EnvironmentObject var settingStore: SettingStore
    
    @State private var showSettings = false
//    @State private var showShareSheet = false
    @State private var showDocumentSheet = false
    
    private var calibreDB: CalibreDB {
        return try! CalibreDB(settingStore: settingStore)
    }
    
    private var calibrePath: URL {
        return try! settingStore.getCalibreURL()
    }
    
    var books: [Book] {
        var books: [Book] = []
        
        do {
            let dbQueue = try calibreDB.load()
            try dbQueue.read { db -> [Book] in
                books = try Book.limit(100).fetchAll(db)
                return books
            }
        } catch {
            print("Error: Unable to get books")
        }
        return books
    }
    
    var profileButton: some View {
        Button(action: { self.showSettings.toggle() }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .accessibility(label: Text("User Profile"))
                .padding()
        }
    }
    
//    var shareButton: some View {
//        Button(action: { self.showShareSheet.toggle() }) {
//            Image(systemName: "square.and.arrow.up")
//                .imageScale(.large)
//                .accessibility(label: Text("Share"))
//                .padding()
//        }
//    }
    
    var docShareButton: some View {
        Button(action: { self.showDocumentSheet.toggle() }) {
            Image(systemName: "square.and.arrow.up")
                .imageScale(.large)
                .accessibility(label: Text("Share"))
                .padding()
        }
    }

    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    QGrid(books,
                          columns: 3,
                          columnsInLandscape: 6,
                          vSpacing: 10,
                          hSpacing: 10,
                          vPadding: 0,
                          hPadding: 00) { book in
                        NewGridCell(book: book, calibreDB: self.calibreDB)
                    }
                }
                .navigationBarTitle("CalibreSync")
                .navigationBarItems(trailing:
                    HStack {
                        profileButton
//                        shareButton
                })
                .sheet(isPresented: $showSettings) {
                    SettingsView().environmentObject(self.settingStore)
                }
            }
//            .sheet(isPresented: $showShareSheet) {
//                ShareSheet(activityItems: ["Hello World"])
//            }
        }
    }
}

struct NewGridCell: View {
    var book: Book
    var calibreDB: CalibreDB
    
    var body: some View {
        NavigationLink(destination: BooksDetail(book: book, calibreDB: calibreDB)) {
            ZStack {
//                ImageView(withURL: URL(fileURLWithPath: calibreDB.getCalibrePath().path + "/" + book.path + "/cover.jpg").absoluteString)
//                ImageView(withURL: calibreDB.getCalibrePath().appendingPathComponent("/").appendingPathComponent(book.path).appendingPathComponent("cover.jpg"))
//                    .padding([.horizontal, .top], 2.0)
                
                RemoteImage(
                    with: calibreDB.getCalibrePath().appendingPathComponent("/").appendingPathComponent(book.path).appendingPathComponent("cover.jpg"),
                    imageView: { Image(uiImage: $0).resizable() },
                    loadingPlaceHolder: { ProgressView(progress: $0) },
                    errorPlaceHolder: { ErrorView(error: $0) },
                    config: Config(transition: .scale, imageProcessor: GaussianBlurImageProcessor()),
                    completion: { (status) in
                        switch status {
                        case .success(let image): print("success! imageSize:", image.size)
                        case .failure(let error): print("failure... error:", error.localizedDescription)
                        }
                    }
                ).frame(width: 80, height: 100, alignment: .center)
                
//                Text(book.title)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    struct ProgressView: View {
        let progress: Float
        var body: some View {
            return GeometryReader { (geometry) in
                ZStack(alignment: .bottom) {
                    Rectangle().fill(Color.gray)
                    Rectangle().fill(Color.green)
                        .frame(width: nil, height: geometry.frame(in: .global).height * CGFloat(self.progress), alignment: .bottom)
                }
            }
        }
    }
    struct ErrorView: View {
        let error: Error
        var body: some View {
            ZStack {
                Rectangle().fill(Color.red)
                Text(error.localizedDescription).font(Font.system(size: 8))
            }
        }
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage(imageLiteralResourceName: "cover")
    
    init(withURL url:URL) {
        print("init")
        imageLoader = ImageLoader(urlString:url)
    }
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
//                .frame(width:80, height:100)
        .padding(10)
        .onReceive(imageLoader.didChange) { data in
            self.image = UIImage(data: data) ?? UIImage()
        }
    }
}

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var task: URLSessionDataTask!
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString url:URL) {
                
        DispatchQueue.global(qos: .userInitiated).async {
            self.task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.data = data
                }
            }
            self.task.resume()
        }
    }
    
    deinit {
        task.cancel()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environmentObject(SettingStore())
//    }
//}
