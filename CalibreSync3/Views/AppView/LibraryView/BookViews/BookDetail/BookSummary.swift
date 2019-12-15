//
//  BookSummary.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/14/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI
import GRDB

struct BookSummary: View {
    var book: DiskBook
    var dbQueue: DatabaseQueue
    @State var comments: [DiskBookComment]?
    
    func getComments() -> [DiskBookComment] {
        do {
            return try dbQueue.read { db in
                //                try book.comments.fetchAll(db)
                try DiskBookComment
                    .filter(Column("book") == book.id)
                    .fetchAll(db)
            }
        } catch {
            return []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("SUMMARY")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .padding(.bottom, 5)
                Spacer()
            }
            ForEach(getComments()) { comment in
                Text(comment.text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
            }
        }
    .padding(10)
    }
}

//struct BookSummary_Previews: PreviewProvider {
//    static var previews: some View {
//        BookSummary()
//    }
//}
