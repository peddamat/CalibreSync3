//
//  DirectoryPickerView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/1/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import Foundation
import SwiftUI
import MobileCoreServices

struct FilePickerController: UIViewControllerRepresentable {
    var callback: (URL) -> ()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePickerController>) {
        // Update the controller
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        NSLog("Making the picker")
        let controller = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        
        controller.delegate = context.coordinator
        NSLog("Setup the delegate \(context.coordinator)")
        
        return controller
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerController
        
        init(_ pickerController: FilePickerController) {
            self.parent = pickerController
            NSLog("Setup a parent")
            NSLog("Callback: \(parent.callback)")
        }
       
        public func documentPicker(_ picker: UIDocumentPickerViewController, didPickDocumentsAt: [URL]) {
            NSLog("Selected a document: \(didPickDocumentsAt[0])")
            parent.callback(didPickDocumentsAt[0])
        }
        
        func documentPickerWasCancelled(_ picker: UIDocumentPickerViewController) {
            NSLog("Document picker was thrown away :(")
        }
        
        deinit {
            NSLog("Coordinator going away")
        }
    }
}

struct DirectoryPickerView: View {
    var callback: (URL) -> ()

    var body: some View {
        FilePickerController(callback: callback)
    }
}

#if DEBUG
struct DirectoryPickerView_Preview: PreviewProvider {
    static var previews: some View {
        func filePicked(_ url: URL) {
            NSLog("Filename: \(url)")
        }
        return DirectoryPickerView(callback: filePicked)
            .aspectRatio(3/2, contentMode: .fit)
    }
}
#endif
