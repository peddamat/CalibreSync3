//
//  ContentView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Combine
import GRDB
import SwiftUI

//import Grid
//import Fuzzy

struct SlideMenuView: View {
  @ObservedObject var store = Store.shared
  @State var bookCache: BookCache

  // Modal overlay toggles
  @State private var showSettings = false
  @State private var showShareSheet = false
  @State private var showDocumentSheet = false
  @State var showMenu = false

  var profileButton: some View {
    Button(action: { self.showSettings.toggle() }) {
      Image(systemName: "ellipsis")
        .imageScale(.large)
        .accessibility(label: Text("More"))
        .padding()
    }
  }

  var shareButton: some View {
    Button(action: {
      self.store.gridOnlyShowDownloaded.toggle()
      NotificationCenter.default.post(name: .refreshBookCache, object: nil)
    }) {
      Image(systemName: self.store.gridOnlyShowDownloaded ? "bookmark.fill" : "bookmark")
        .imageScale(.large)
        .accessibility(label: Text("Share"))
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
      //            MainView(bookCache: self.$bookCache).environmentObject(self.store)
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          LibraryView(bookCache: self.bookCache).environmentObject(self.store)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .offset(x: self.showMenu ? geometry.size.width / 2.0 : 0)
            .disabled(self.showMenu ? true : false)
          //                    .gesture(drag)
          if self.showMenu {
            SideMenuView()
              .frame(width: geometry.size.width / 2)
              .transition(.move(edge: .leading))
          }
        }

      }
      .navigationBarTitle("Side Menu", displayMode: .inline)
      .navigationBarItems(
        leading: (Button(action: {
          withAnimation {
            self.showMenu.toggle()
          }
        }) {
          Image(systemName: "line.horizontal.3")
            .imageScale(.large)
        })
      )

      .navigationBarTitle("CalibreSync", displayMode: .inline)
      .navigationBarItems(
        leading: menuButton,
        trailing: HStack {
          Spacer()
          shareButton
          profileButton

        })
    }
    .navigationViewStyle(
      StackNavigationViewStyle()
    )
    .sheet(
      isPresented: $showSettings,
      onDismiss: {
        NotificationCenter.default.post(name: .refreshBookCache, object: nil)
      }
    ) {
      SettingsView().environmentObject(self.store)

    }
  }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environmentObject(Store())
//    }
//}
