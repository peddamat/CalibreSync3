//
//  SceneDelegate.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var settingStore = SettingStore()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
                
        // Create the SwiftUI view that provides the window contents.
//        let contentView = ContentView(calibrePath: readCalibrePath().path).environmentObject(settingStore)
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
//            setupFileCoordination()
            window.rootViewController = UIHostingController(rootView: AppRootView().environmentObject(settingStore))
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
//    func readCalibrePath() -> URL {
//        var urlResult = false
//        let url = self.settingStore.calibreRoot
//        
//        let folderURL = try! URL(resolvingBookmarkData: url, options: [], relativeTo: nil, bookmarkDataIsStale: &urlResult)
//        
//        print(folderURL)
//        return folderURL
//    }
//    
//    func setupFileCoordination() {
//        let error: NSErrorPointer = nil
//        let filePath = readCalibrePath().path
//        
//        let pickedFolderURL = URL(fileURLWithPath: filePath)
//        let shouldStopAccessing = pickedFolderURL.startAccessingSecurityScopedResource()
//        defer { if shouldStopAccessing { pickedFolderURL.stopAccessingSecurityScopedResource() }}
//        
//        NSFileCoordinator().coordinate(readingItemAt: pickedFolderURL, error: error)
//        { (folderURL) in
//            do {
//                print("Scene Delegate: Completed setting up file coordination")
//                let keys : [URLResourceKey] = [.nameKey, .isDirectoryKey]
//                let fileList = try FileManager.default.enumerator(at: folderURL, includingPropertiesForKeys: keys)
//                for file  in fileList! {
//                    print(file)
//                }
//            } catch let error {
//                print("fucked")
//            }
//        }
//    }
    
}

