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
        var TAB_HEIGHT : CGFloat
        if #available(macOS 11.0, *) {
            TAB_HEIGHT = 79
        } else {
            TAB_HEIGHT = 78
        }
        if let currentWindow = view.window, let currentContentView = tabView.subviews.first {
            let windowSize = currentWindow.frame.size
            let contentSize = currentContentView.frame.size
            let heightDiff = contentSize.height+TAB_HEIGHT - windowSize.height
            let targetOrigin = NSPoint(x: currentWindow.frame.origin.x, y: currentWindow.frame.origin.y-heightDiff)
            let targetSize = NSSize(width: contentSize.width, height: contentSize.height+TAB_HEIGHT)
            let targetRect = NSRect(origin: targetOrigin, size: targetSize)
            currentWindow.animator().setFrame(targetRect, display: true)
        }
    }
}
