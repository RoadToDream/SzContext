//
//  TabViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/4/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa

class TabViewController: NSTabViewController {

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        if let currentWindow = view.window, let currentContentView = tabView.subviews.first {
            let windowSize = currentWindow.frame.size
            let contentSize = currentContentView.frame.size
            let heightDiff = contentSize.height+78 - windowSize.height
            let targetOrigin = NSPoint(x: currentWindow.frame.origin.x, y: currentWindow.frame.origin.y-heightDiff)
            let targetSize = NSSize(width: contentSize.width, height: contentSize.height+78)
            let targetRect = NSRect(origin: targetOrigin, size: targetSize)
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                context.duration = 0.2
                context.allowsImplicitAnimation = true
                currentWindow.setFrame(targetRect, display: true)
            }, completionHandler: nil)
        }
    }
    
}
