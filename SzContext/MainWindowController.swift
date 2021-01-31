//
//  WindowController.swift
//  SzContext
//
//  Created by Jiawei Duan on 2018/8/27.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate{
    
    override func windowDidLoad(){
        window?.isMovableByWindowBackground = true
    }
    
    func windowDidBecomeMain(_ notification: Notification) {
        NotificationCenter.default.post(name: NSNotification.Name("refreshState"), object: nil)
    }
}
