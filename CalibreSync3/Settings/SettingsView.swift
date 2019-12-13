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
    
    @State private var downloaded: Bool = true
    @State private var items = 33
    @State private var selectedOrder = 0
    
    func saveCalibrePath(_ url: URL) {
        NSLog(url.path)
                        
        do {
            let shouldStopAccessing = url.startAccessingSecurityScopedResource()
            defer { if shouldStopAccessing { url.stopAccessingSecurityScopedResource() } }
            
            let bookmark = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            
//            self.settingStore.calibreRemoteLibraryBookmark = bookmark
//            try! CalibreDB.cacheRemoteCalibreDB(settingStore: settingStore, calibreRemoteURL: url)
        } catch let error {
            
        }
    }
    
    enum VegetableList: CaseIterable, Hashable, Identifiable {
        case asparagus
        case celery
        case shallots
        case cucumbers

        var name: String {
            return "\(self)".map {
                $0.isUppercase ? " \($0)" : "\($0)" }.joined().capitalized
        }
        var id: VegetableList {self}
    }
    
    var body: some View {
        NavigationView {
            Form {
                Stepper(onIncrement: {
                    self.settingStore.itemsPerScreen += 3
                }, onDecrement: {
                    self.settingStore.itemsPerScreen -= 3
                }) {
                    Text("Items Per Screen: \(self.settingStore.itemsPerScreen)")
                }
                
                Section(header: Text("SORT PREFERENCES")) {
                    Picker(selection: self.$settingStore.gridDisplayOrder,
                           label: Text("Display Order"))
                    {
                        ForEach(SettingStore.DisplayOrders.allCases) { v in
                            Text(v.rawValue)
                        }
                    }

                    Picker(selection: self.$settingStore.gridDisplayDirection,
                           label: Text("Direction"))
                    {
                        ForEach(SettingStore.DisplayDirections.allCases) { v in
                            Text(v.rawValue)
                        }
                    }
                }
                
                Section(header: Text("FILTER PREFERENCES")) {
                    Toggle(isOn: self.$settingStore.gridOnlyShowDownloaded){
                        Text("Downloaded Only")
                    }
                }
                Section(header: Text("ADVANCED")) {
                    List {
                        Button(action: {
                            self.show_modal = true
                        }) {
                            Text("Select Calibre Directory")
                        }.sheet(isPresented: self.$show_modal) {
                            DirectoryPickerView(callback: self.saveCalibrePath)
                        }
                        
                        Button(action: {
                            self.show_modal = true
                        }) {
                            Text("Delete Cached Files")
                        }.sheet(isPresented: self.$show_modal) {
                            DirectoryPickerView(callback: self.saveCalibrePath)
                        }
                    }
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

