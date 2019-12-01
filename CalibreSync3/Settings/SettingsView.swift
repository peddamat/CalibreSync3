//
//  SettingsView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Combine
import SwiftUI

struct SettingsView: View {
    
    @State private var show_modal: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settingStore: SettingStore
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    print("Settings button clicked")
                }) {
                    Text("Select Calibre Directory")
                }
            }
                
            .navigationBarTitle("Settings")
            .navigationBarItems(
                leading:
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                            .foregroundColor(.black)
                    }),
                trailing:
                    Button(action: {
                        print("Save button clicked")
                    }, label: {
                        Text("Save")
                            .foregroundColor(.black)
                    })
            )
        }
        .onAppear {
            // Setup view from settingsStore
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(SettingStore())
    }
}

