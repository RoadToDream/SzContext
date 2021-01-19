//
//  PreferenceNewItemViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/16/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa

class PreferenceNewItemViewController: PreferenceViewController {
    
    @IBOutlet weak var newItemsTableView: NSTableView!
    @IBOutlet weak var newItemsScrollView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(macOS 11.0, *) {
            newItemsScrollView.layer?.masksToBounds = true
            newItemsScrollView.layer?.cornerRadius = 10
            newItemsScrollView.borderType = .noBorder
            newItemsTableView.style = .inset
        }
        
    }
    
    override func viewWillAppear() {
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    override func viewDidDisappear() {
        DistributedNotificationCenter.default().removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }

}

