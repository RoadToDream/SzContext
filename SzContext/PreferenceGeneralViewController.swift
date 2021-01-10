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
    
    var tipExtensionEnableWindowController : NSWindowController?
    
    @IBOutlet weak var extensionButton: NSButton!
    @IBOutlet weak var folderAccessButton: NSButton!
    @IBOutlet weak var extensionStauts: NSTextField!
    @IBOutlet weak var folderAccessStatus: NSTextField!
    @IBOutlet weak var showIconsCheckbox: NSButton!
    @IBOutlet weak var showIconsTip: NSButton!
    
    @IBAction func openSystemPreference(_ sender: Any) {
        FinderSync.FIFinderSyncController.showExtensionManagementInterface()
        openTipExtensionEnableWindow()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(onMonitorFinderExtension(_:)), name: Notification.Name("onMonitorFinderExtension"), object: nil,suspensionBehavior:.deliverImmediately)
    }
    
    @IBAction func grantHomeFolderAccess(_ sender: Any) {
        debugPrint(BookmarkManager.allowFolder(for: FileManager.default.homeDirectoryForCurrentUser, with: .bookmarkAccessFolder, note: NSLocalizedString("instruction.openFolder", comment: "")) as Any)
        BookmarkManager.loadMainBookmarks(with: .bookmarkAccessFolder)
        bookmarkXPCUpdate()
        NotificationCenter.default.post(name: Notification.Name("onMonitorStatus"), object: nil)
    }
    
    @IBAction func showIcons(_ sender: Any) {
        let shouldShowIcons = showIconsCheckbox.state == .on
        PreferenceManager.set(for: .showIconsOption, with: shouldShowIcons)
    }
    
    @IBAction func showIconsTip(_ sender: Any) {
        let showIconsTipPopover = NSPopover.init()
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        if PreferenceManager.bool(for: .showIconsOption) {
            showIconsTipPopover.contentViewController = (storyboard.instantiateController(withIdentifier: "tipMenuWithImage") as! NSViewController)
        } else {
            showIconsTipPopover.contentViewController = (storyboard.instantiateController(withIdentifier: "tipMenuWithoutImage") as! NSViewController)
        }
        showIconsTipPopover.animates = true
        showIconsTipPopover.contentSize = NSSize(width: 225, height: 240)
        showIconsTipPopover.behavior = NSPopover.Behavior.transient
        showIconsTipPopover.show(relativeTo: showIconsTip.visibleRect, of: showIconsTip, preferredEdge: NSRectEdge.maxX)
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
        refreshState()
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
    func openTipExtensionEnableWindow(){
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        tipExtensionEnableWindowController = (storyboard.instantiateController(withIdentifier: "tipExtensionEnableWindowControllerID") as! NSWindowController)
        tipExtensionEnableWindowController?.showWindow(self)
        tipExtensionEnableWindowController?.window?.level = .normal
    }
    
    func closeTipExtensionEnableWindow(){
        if ((tipExtensionEnableWindowController?.isWindowLoaded) != nil) {
            tipExtensionEnableWindowController!.close()
        }
    }
    
    @objc func onMonitorFinderExtension(_ notification:Notification) {
        closeTipExtensionEnableWindow()
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
        showIconsCheckbox.state = PreferenceManager.bool(for: .showIconsOption) ? .on : .off
    }
    
}
