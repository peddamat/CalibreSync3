//
//  SearchView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/4/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI
import Combine

struct SearchView: View {
    @ObservedObject var store = Store.shared

    let array = ["Peter", "Paul", "Mary", "Anna-Lena", "George", "John", "Greg", "Thomas", "Robert", "Bernie", "Mike", "Benno", "Hugo", "Miles", "Michael", "Mikel", "Tim", "Tom", "Lottie", "Lorrie", "Barbara"]
//    @State private var searchText = ""
    @State private var showCancelButton: Bool = false


    var body: some View {

        // Search view
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")

                TextField("Search", text: self.$store.searchString, onEditingChanged: { isEditing in
                    self.showCancelButton = true
                }, onCommit: {
                    NSLog("Search: Enter pressed.")
                }).foregroundColor(.primary)

                Button(action: {
                    self.store.searchString = ""
                }) {
                    Image(systemName: "xmark.circle.fill").opacity(self.store.searchString.isEmpty ? 0.0 : 1.0)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)

            if showCancelButton  {
                Button("Cancel") {
                        UIApplication.shared.endEditing(true) // this must be placed before the other commands here
                        self.store.searchString = ""
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

class MyModel: ObservableObject {
    var didChange = PassthroughSubject<Bool, Never>()
    
    @Published var refreshing: Bool = false {
        didSet {
            if oldValue == false && refreshing == true {
                self.refresh()
            }
        }
    }
    
    @Published var loading: Bool = false {
        didSet {
            if oldValue == false && loading == true {
                self.load()
//                didChange.send(loading)
            }
        }
    }
    
    var idx = 0
    
    func refresh() {
        // Simulate async task
        NotificationCenter.default.post(name: .refreshBookCache, object: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.refreshing = false
        }
    }
    
    func load() {
        // Simulate async task
        NotificationCenter.default.post(name: .loadMoreBookCache, object: nil)
        self.loading = false

//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//        }
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
