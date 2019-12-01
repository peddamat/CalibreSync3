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
    
    var profileButton: some View {
        Button(action: { self.showSettings.toggle() }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .accessibility(label: Text("User Profile"))
                .padding()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text(self.settingStore.getCalibrePath())
            }
            .navigationBarTitle("CalibreSync")
            .navigationBarItems(trailing: profileButton)
            .sheet(isPresented: $showSettings) {
                SettingsView().environmentObject(self.settingStore)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SettingStore())
    }
}
