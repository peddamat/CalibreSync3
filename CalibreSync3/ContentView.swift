//
//  ContentView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingStore: SettingStore
    @State private var showSettings = false

    var body: some View {

        Button(action: {
            self.showSettings.toggle()
        }) {
            Text("Open Settings Screen")
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SettingStore())
    }
}
