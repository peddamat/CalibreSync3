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
    
    func saveCalibrePath(_ url: URL) {
        NSLog(url.path)
        
        do {
            let shouldStopAccessing = url.startAccessingSecurityScopedResource()
            defer { if shouldStopAccessing { url.stopAccessingSecurityScopedResource() } }
            
            let bookmark = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            self.settingStore.calibreRemoteLibraryBookmark = bookmark
        } catch let error {
            
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    self.show_modal = true
                }) {
                    Text("Select Calibre Directory")
                }.sheet(isPresented: self.$show_modal) {
                    DirectoryPickerView(callback: self.saveCalibrePath)
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
                        NSLog("Save button clicked")
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

