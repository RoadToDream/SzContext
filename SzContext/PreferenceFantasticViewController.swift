//
//  PreferenceFantasticViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/29/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//


import Foundation
import Cocoa

class PreferenceFantasticViewController: PreferenceViewController {
    @IBOutlet weak var showOpenRecentCheckbox: NSButton!
    @IBOutlet weak var showOpenRecentButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshState()
    }
    
    override func viewWillAppear() {
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    @IBAction func showOpenRecentCheckboxAction(_ sender: Any) {
        let shouldShowOpenRecent = showOpenRecentCheckbox.state == .on
        PreferenceManager.set(for: .showOpenRecent, with: shouldShowOpenRecent)
    }
    @IBAction func showOpenRecentButtonAction(_ sender: Any) {
        let resourceURL = Bundle.main.resourceURL?.appendingPathComponent("script")
        NSWorkspace.shared.open(resourceURL!)
        XPCServiceManager.openXPCScriptDirectory()
    }
    
    override func viewDidDisappear() {
        DistributedNotificationCenter.default().removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refreshState() {
        showOpenRecentCheckbox.state = PreferenceManager.bool(for: .showOpenRecent) ? .on : .off
    }

}
