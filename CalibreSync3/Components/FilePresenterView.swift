//
//  FilePresenterView.swift
//  PencilDataParse
//
//  Created by Andrew Pouliot on 6/8/19.
//  Copyright © 2019 Darknoon. All rights reserved.
//

import SwiftUI

struct FilePresenterUIView : UIViewRepresentable {
    
    var file: URL
    var showing = false
    var onDismiss: () -> ()
    
    //  init(file: URL, onDismiss) {
    //    self.file = file
    //  }
    
    typealias UIViewType = ProvideViewCoordsView
    
    // Provides a callback that we use to display the controller from the right rect on screen
    class ProvideViewCoordsView : UIView {
        
        var didAppear : (UIView, CGRect) -> Void = {_, _ in }
        
        override func didMoveToWindow() {
            if self.window == nil { return }
            didAppear(self, self.bounds)
        }
    }
    
    class Coordinator : NSObject, UIDocumentInteractionControllerDelegate {
        typealias Parent = FilePresenterUIView
        
        let parent: Parent
        let interaction: UIDocumentInteractionController
        
        init(_  v: Parent) {
            self.parent = v
            let url = v.file
            interaction = UIDocumentInteractionController(url: url)
            super.init()
            interaction.delegate = self
        }
        
        // TODO: The modal isn't reliably dismissed, fix this
        func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
            NSLog("should dismiss")
            self.parent.onDismiss()
        }
        
        func setup(_ v: ProvideViewCoordsView) {
            v.didAppear = {view, rect in
                NSLog("Presenter layout \(view) \(rect)")
                if !self.parent.showing {
                    self.interaction.presentOpenInMenu(from: rect, in: view, animated: true)
                }
            }
        }
    }
    
    typealias _Context = UIViewRepresentableContext<FilePresenterUIView>
    
    
    // TODO: See if we can completely hide the ugly gray background...
    func makeUIView(context: _Context) -> ProvideViewCoordsView {
        let v = ProvideViewCoordsView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        v.backgroundColor = UIColor.red.withAlphaComponent(0.0)
        v.setNeedsLayout()
        context.coordinator.setup(v)
        return v
    }
    
    func updateUIView(_ uiView: UIViewType, context: _Context) {
        if let file = context.coordinator.interaction.url {
            if file != self.file {
                NSLog("Changed URL unexpectedly!")
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
}

