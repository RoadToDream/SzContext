//
//  PreferenceAboutViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/3/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Cocoa

class PreferenceAboutViewController: PreferenceViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshState()
    }

    override var representedObject: Any? {
        didSet {
            
        }
    }
    
    func refreshState() {
        
    }
}

class HyperTextField: NSTextField {
    override func mouseDown(with event: NSEvent) {
        self.textColor = .blue
    }
    override func mouseUp(with event: NSEvent) {
        self.textColor = .controlAccentColor
        NSWorkspace.shared.open(URL(string: self.stringValue)!)
    }
}
