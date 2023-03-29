//
//  LibraryView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/13/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI
//import Fuzzy
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
            
        }
        
    }
}

//struct LibraryView_Previews: PreviewProvider {
//    static var previews: some View {
//        LibraryView()
//    }
//}
