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
    
    var tipWindowController : NSWindowController?
    
    @IBOutlet weak var extensionButton: NSButton!
    @IBOutlet weak var folderAccessButton: NSButton!
    @IBOutlet weak var extensionStauts: NSTextField!
    @IBOutlet weak var folderAccessStatus: NSTextField!
    
    @IBAction func openSystemPreference(_ sender: Any) {
        FinderSync.FIFinderSyncController.showExtensionManagementInterface()
        openTipWindow()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(onMonitorFinderExtension(_:)), name: Notification.Name("onMonitorFinderExtension"), object: nil,suspensionBehavior:.deliverImmediately)
    }
    
    @IBAction func grantHomeFolderAccess(_ sender: Any) {
        debugPrint(BookmarkManager.allowFolder(for: URL(string: "~/"), with: .bookmarkAccessFolder, note: NSLocalizedString("instruction.openFolder", comment: "")) as Any)
        BookmarkManager.loadMainBookmarks(with: .bookmarkAccessFolder)
        bookmarkXPCUpdate()
        NotificationCenter.default.post(name: Notification.Name("onMonitorStatus"), object: nil)
    }
    @IBAction func resetPreference(_ sender: Any) {
        if NotifyManager.messageNotify(message: NSLocalizedString("warning.resetPreference", comment: ""), inform: "", style: .warning) {
            PreferenceManager.reset()
            bookmarkXPCUpdate()
            NotificationCenter.default.post(name: Notification.Name("onMonitorStatus"), object: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector: #selector(refreshState),name: Notification.Name("onMonitorStatus"),object: nil)
    }
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    override func viewDidDisappear() {
        DistributedNotificationCenter.default().removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    func openTipWindow(){
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        tipWindowController = (storyboard.instantiateController(withIdentifier: "extensionTipWindowControllerID") as! NSWindowController)
        tipWindowController?.showWindow(self)
        tipWindowController?.window?.level = .normal
    }
    
    func closeTipWindow(){
        if ((tipWindowController?.isWindowLoaded) != nil) {
            tipWindowController!.close()
        }
    }
    
    @objc func onMonitorFinderExtension(_ notification:Notification) {
        closeTipWindow()
    }
    
    @objc func refreshState() {
        if FinderSync.FIFinderSyncController.isExtensionEnabled {
            extensionButton.image = NSImage(named: "NSStatusAvailable")
            extensionStauts.stringValue = "Extension enabled"
        } else {
            extensionButton.image = NSImage(named: "NSStatusUnavailable")
            extensionStauts.stringValue = "Extension not enabled"
        }
        if !BookmarkManager.isBookmarkEmpty(with: PreferenceManager.Key.urlAccessFolder) {
            folderAccessButton.image = NSImage(named: "NSStatusAvailable")
            folderAccessStatus.stringValue = PreferenceManager.url(for: .urlAccessFolder)[0]+" is granted"
        } else {
            folderAccessButton.image = NSImage(named: "NSStatusUnavailable")
            folderAccessStatus.stringValue = "Currently there is no folder granted."
        }
    }
    
}
