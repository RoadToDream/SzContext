//
//  PreferenceGeneralViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/3/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Cocoa
import FinderSync

class PreferenceGeneralViewController: PreferenceViewController {
    
    @IBAction func openSystemPreference(_ sender: Any) {
        FinderSync.FIFinderSyncController.showExtensionManagementInterface()
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        let tipWindowController = (storyboard.instantiateController(withIdentifier: "extensionTipWindowControllerID") as! NSWindowController)
        tipWindowController.showWindow(self)
        tipWindowController.window?.orderFrontRegardless()
    }
    
    @IBAction func grantHomeFolderAccess(_ sender: Any) {
        debugPrint(BookmarkManager.allowFolder(for: URL(string: "~/"), with: .bookmarkAccessFolder, note: NSLocalizedString("instruction.openFolder", comment: "")) as Any)
        BookmarkManager.loadMainBookmarks(with: .bookmarkAccessFolder)
        bookmarkXPCUpdate()
    }
    @IBAction func resetPreference(_ sender: Any) {
        if NotifyManager.messageNotify(message: NSLocalizedString("warning.resetPreference", comment: ""), inform: "", style: .warning) {
            PreferenceManager.reset()
            bookmarkXPCUpdate() 
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshState()
    }
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    
    func refreshState() {
        
    }
}
