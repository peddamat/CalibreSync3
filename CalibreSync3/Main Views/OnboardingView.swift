//
//  OnboardingView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/4/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI
import PromiseKit

struct OnboardingView: View {
    @State private var show_modal: Bool = false
    @EnvironmentObject var settingStore: SettingStore
    
    @State private var showFoundCalibreDB: Bool = false
    @State private var step2: Bool = false
    @State private var showDatabaseError: Bool = false
    
    @State private var copyProgress: CGFloat = 0.0
    
    @State private var pickedURL: URL? = nil
    
    let bgColor = Color(red: 244/255.0, green: 236/255.0, blue: 230/255.0)
    
    func getFolder() -> Promise<Bool> {
        return Promise { seal in
            seal.fulfill(true)
        }
    }
    
    func saveCalibrePath(_ pickedFolderURL: URL) {
        
//        FileHelper.accessSecurityScopedFolder(url: pickedFolderURL)
        
        firstly {
            getFolder()
        }.then { _ in
            CalibreDB.copyDatabase(at: pickedFolderURL, to: FileHelper.getDocumentsDirectory()!)
        }.then { (localDBURL) in
            // Make sure we can find the Calibre database
            CalibreDB.openDatabase(atPath: localDBURL.path)
        }.then { (dbQueue) in
            // Retrieve books
            CalibreDB.promiseGetBookCoverURLs(dbQueue: dbQueue, withBaseURL: pickedFolderURL)
//            CalibreDB.promiseCacheRemoteCalibreDB(settingStore: self.settingStore, calibreRemoteURL: pickedFolderURL)
        }.then { (bookCoverURLs) in
            // Cache book covers
            FileHelper.promiseCopyBookCovers(covers: bookCoverURLs,
                                             at: pickedFolderURL,
                                             to: FileHelper.getDocumentsDirectory()!)
        }.ensure {
        }.done { (result) in
            self.step2 = true
            self.pickedURL = pickedFolderURL

        }.catch { (error) in
            NSLog("Can't find a database in \(pickedFolderURL.path)")
            print(error)
            self.showDatabaseError = true
        }
    }
    
    var body: some View {
        
        ZStack {
            Color.init(red: 244/255.0, green: 236/255.0, blue: 230/255.0)
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 30) {
                
                HStack(spacing:10) {
                    Text("Welcome to CalibreSync")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.black)
                    
                    Spacer()
                }
                
                Text("To get started, we'll need to connect to your Calibre Library.")
                
                Button(action: {
                    self.show_modal = true
                }) {
                    Text("Select Calibre Library Location")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(red: 0/255, green: 212/255, blue: 255/255))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                if (self.showFoundCalibreDB) {
                    Text("Great!  Now we're going to download a local copy of your database.  This may take a few minutes.")

                    HStack {
                        Spacer()
                        SimpleProgressBar(circleProgress: $copyProgress, width: 200, height: 20, progressColor: Color(red: 0/255, green: 212/255, blue: 255/255), staticColor: .gray)
                        Spacer()
                    }
                }

                if (self.step2) {
                    Text("Awesome, we're ready to go.  Click \"Next\" to get started.")
                        
                    Text("If you ever need to change your Calibre Library location, you can do so from the Setting menu.")
                    
                    Button(action: {
                        // Tell the rest of the application that we're ready
                        self.settingStore.saveRemoteLibraryBookmark(self.pickedURL!)
                    }) {
                        Text("Next")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color(red: 0/255, green: 212/255, blue: 255/255))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                
                if (self.showDatabaseError) {
                    Text("Uh oh, we couldn't find a Calibre database in this location.  Try selecting another folder.")
                }
                
                Spacer()
            }
            .padding(30)
            
        }.sheet(isPresented: self.$show_modal) {
            DirectoryPickerView(callback: self.saveCalibrePath)
        }
    }
}

struct SimpleProgressBar : View {
    
    @Binding var circleProgress: CGFloat
    
    var width: CGFloat
    var height: CGFloat
    var progressColor: Color?
    var staticColor: Color?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(self.staticColor ?? .gray)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(self.progressColor ?? .blue)
                    .frame(width: self.circleProgress*geometry.size.width, height: geometry.size.height)
            }
        }
            .frame(width: width, height: height)
    }

}

//struct SimpleProgresBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SimpleProgressBar(circleProgress: .constant(0.2), width: 200, height: 10, progressColor: .blue, staticColor: .gray)
//    }
//}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
