//
//  FirstStartUpWindowController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/8/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa

class FirstStartUpWindowController: NSWindowController, NSWindowDelegate{
    
    override func windowDidLoad(){
        window?.isMovableByWindowBackground = true
    }
    
}
