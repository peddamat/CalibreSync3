//
//  AppRootView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/3/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var settingStore: SettingStore
    @State private var selection = 1
    
    var body: some View {
        Group {
            if settingStore.calibreRemoteLibraryBookmark == nil {
                OnboardingView().environmentObject(settingStore)
            } else {
                TabView(selection: $selection) {
                    SideMenuView()
                    .tabItem {
                            VStack {
                                Image(systemName: "square.grid.3x2.fill")
                                Text("Home")
                            }
                        }
                        .tag(0)
                    ContentView().environmentObject(settingStore)
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
