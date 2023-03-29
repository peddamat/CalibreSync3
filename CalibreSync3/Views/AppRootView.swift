//
//  AppRootView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/3/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct AppRootView: View {
  @ObservedObject var store = Store.shared
  @State private var selection = 1

  var body: some View {
    Group {
      // If we don't
      if store.remoteLibraryBookmark == nil {
        SetupView().environmentObject(store)
        //                SettingsView().environmentObject(store)
      } else {
        TabView(selection: $selection) {
          HomeView()
            .tabItem {
              VStack {
                Image(systemName: "square.grid.3x2.fill")
                Text("Home")
              }
            }
            .tag(0)
          SlideMenuView(bookCache: BookCache()).environmentObject(store)
            .tabItem {
              VStack {
                Image(systemName: "rectangle.3.offgrid.fill")
                Text("Library")
              }
            }
            .tag(1)
        }
        .accentColor(.yellow)
      }
    }
  }
}

//struct AppRootView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppRootView()
//    }
//}
