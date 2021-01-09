//
//  ViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 2018/8/25.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
            
        }
    }
}

class IMDragView: NSImageView{
    override public func mouseDown(with event: NSEvent) {
            window?.performDrag(with: event)
        }
}
