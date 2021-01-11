//
//  PreferenceAboutViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/3/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Cocoa
import Sparkle

class PreferenceAboutViewController: PreferenceViewController {

    @IBOutlet weak var automaticallyCheckForUpdatesCheckbox: NSButton!
    
    @IBAction func automaticallyCheckForUpdates(_ sender: Any) {
        let shouldAutomaticallyCheckForUpdates = automaticallyCheckForUpdatesCheckbox.state == .on
        SUUpdater.shared()?.automaticallyChecksForUpdates = shouldAutomaticallyCheckForUpdates
    }
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        updater?.checkForUpdates(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector: #selector(refreshState),name: Notification.Name("onMonitorStatus"),object: nil)
        refreshState()
    }

    override var representedObject: Any? {
        didSet {
            
        }
    }
    
    @objc func refreshState() {
        if let automaticallyChecksForUpdatesStatus = SUUpdater.shared()?.automaticallyChecksForUpdates {
            if automaticallyChecksForUpdatesStatus {
                automaticallyCheckForUpdatesCheckbox.state = NSControl.StateValue.on
                return
            }
        }
        automaticallyCheckForUpdatesCheckbox.state = NSControl.StateValue.off
    }
}
