//
//  AppRootView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/3/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct AppRootView: View {
    @ObservedObject var settingStore: SettingStore
    
    var body: some View {
        Group {
            if settingStore.calibreRoot != nil {
                ContentView().environmentObject(settingStore)
            } else {
                SettingsView()
            }
        }
    }
}

//struct AppRootView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppRootView()
//    }
//}
