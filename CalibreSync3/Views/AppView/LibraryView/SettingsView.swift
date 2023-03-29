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
  @ObservedObject var store = Store.shared

  @State private var show_modal: Bool = false
  @Environment(\.presentationMode) var presentationMode

  @State private var downloaded: Bool = true
  @State private var items = 55
  @State private var selectedOrder = 0

  func saveCalibrePath(_ url: URL) {
    NSLog(url.path)

    do {
      let shouldStopAccessing = url.startAccessingSecurityScopedResource()
      defer { if shouldStopAccessing { url.stopAccessingSecurityScopedResource() } }

      let bookmark = try url.bookmarkData(
        options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
      self.store.remoteLibraryBookmark = bookmark
      //            try! CalibreDB.cacheRemoteCalibreDB(store: store, calibreRemoteURL: url)
    } catch let error {

    }
  }

  var body: some View {
    NavigationView {
      Form {
        Stepper(
          onIncrement: {
            self.store.itemsPerScreen += 5
          },
          onDecrement: {
            self.store.itemsPerScreen -= 5
          }
        ) {
          Text("Items Per Screen: \(self.store.itemsPerScreen)")
        }

        Section(header: Text("SORT PREFERENCES")) {
          Picker(
            selection: self.$store.gridDisplayOrder,
            label: Text("Display Order")
          ) {
            ForEach(Store.DisplayOrders.allCases) { v in
              Text(v.rawValue)
            }
          }

          Picker(
            selection: self.$store.gridDisplayDirection,
            label: Text("Direction")
          ) {
            ForEach(Store.DisplayDirections.allCases) { v in
              Text(v.rawValue)
            }
          }
        }

        Section(header: Text("FILTER PREFERENCES")) {
          Toggle(isOn: self.$store.gridOnlyShowDownloaded) {
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
          Button(
            action: {
              self.presentationMode.wrappedValue.dismiss()
            },
            label: {
              Text("Cancel")
                .foregroundColor(.black)
            }),
        trailing:
          Button(
            action: {
              NSLog("Save button clicked")
            },
            label: {
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
    SettingsView().environmentObject(Store.shared)
  }
}
