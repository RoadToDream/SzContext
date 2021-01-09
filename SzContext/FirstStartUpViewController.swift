//
//  FirstStartUpViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/8/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Cocoa

class FirstStartUpViewController: NSViewController {
    @IBAction func confirmUnderstanding(_ sender: Any) {
        self.view.window!.windowController!.close()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
            
        }
    }
}
