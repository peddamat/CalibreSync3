//
//  OnboardingView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/4/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @State private var show_modal: Bool = false
    @EnvironmentObject var settingStore: SettingStore
    
    @State private var step1: Bool = false
    @State private var step2: Bool = false
    @State private var step3: Bool = false
    
    @State private var copyProgress: CGFloat = 0.0
    
    @State private var pickedURL: URL? = nil
    
    let bgColor = Color(red: 244/255.0, green: 236/255.0, blue: 230/255.0)
    
    func saveCalibrePath(_ pickedFolderURL: URL) {
        var documentsURL: URL
        // Make sure this is actually a Calibre Library
        do {
            documentsURL = pickedFolderURL.appendingPathComponent("metadata.db")
            NSLog("Checking for database in \(documentsURL.path)")
            
            let shouldStopAccessing = pickedFolderURL.startAccessingSecurityScopedResource()
            defer { if shouldStopAccessing { pickedFolderURL.stopAccessingSecurityScopedResource() }}
            
            try CalibreDB.openDatabase(atPath: documentsURL.path)
        } catch {
            NSLog("Can't find a database in \(documentsURL.path)")
            print(error)

            step3 = true
            return
        }
        
        step1 = true
        
        // Cache a copy of the database
        try! CalibreDB.cacheRemoteCalibreDB(settingStore: settingStore, calibreRemoteURL: pickedFolderURL)
        
        // Cache the book covers
        let covers = BookCache.findAllBookCovers(pickedFolderURL: pickedFolderURL)
        var currCount = 0
        let totalCount = covers.count
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            return
        }
        
        let documentURL = documentsUrl.first!
        
        for coverURL in covers {
            currCount += 1
            DispatchQueue.global(qos: .userInitiated).async {
                let baseURL = coverURL.deletingLastPathComponent()
                let originURL = pickedFolderURL.appendingPathComponent(coverURL.path)
                let destinationURL = documentURL.appendingPathComponent(String(baseURL.path.dropFirst()))
                let destinationURL2 = documentURL.appendingPathComponent(String(baseURL.path.dropFirst())).appendingPathComponent("cover.jpg")
                
                NSLog("Creating directory at: \(destinationURL.path)")
                do {
                    try FileManager.default.createDirectory(
                        atPath: destinationURL.path,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                } catch {
                    NSLog("Couldn't create directory!")
                }
                    
                
                let shouldStopAccessing = pickedFolderURL.startAccessingSecurityScopedResource()
                defer { if shouldStopAccessing { pickedFolderURL.stopAccessingSecurityScopedResource() }}
                
                do {
                    try FileManager.default.copyItem(at: originURL, to: destinationURL2)
                } catch {
                    NSLog("Couldn't copy file")
                    NSLog(" From: \(originURL.path)")
                    NSLog(" To: \(destinationURL2.path)")
                    print("Error: \(error)")
                }
                DispatchQueue.main.async {
                    self.copyProgress = CGFloat(currCount / totalCount)
                }
            }
        }
        
        step2 = true
        self.pickedURL = pickedFolderURL        
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

                if (self.step1) {
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
                        self.settingStore.saveCalibrePath(self.pickedURL!)
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
                
                if (self.step3) {
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
