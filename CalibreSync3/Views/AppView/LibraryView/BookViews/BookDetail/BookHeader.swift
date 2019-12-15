//
//  BookHeader.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/14/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import GRDB
import SwiftUI

struct BookHeader: View {
    var book: DiskBook
    var bookCache: BookCache
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            BookCover(title: (book.title.trimmingCharacters(in: .whitespacesAndNewlines)), downloaded: book.downloaded ?? false,  fetchURL: self.bookCache.getCover(forBook: book))
            
            VStack(alignment: .leading, spacing:5) {
                Text(book.title.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.system(size:16, design:.rounded))
                    .fontWeight(.black)
                
                Text(book.author_sort.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }
}

//struct BookHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        BookHeader()
//    }
//}
