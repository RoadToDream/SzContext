//
//  PreferenceGeneralViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/3/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Cocoa
import FinderSync
import OSLog

class PreferenceGeneralViewController: PreferenceViewController {
    
    var tipExtensionEnableWindowController : NSWindowController?
    var accessFolders = PreferenceManager.urlAccess()
    
    @IBOutlet weak var extensionButton: NSButton!
    @IBOutlet weak var folderAccessButton: NSButton!
    @IBOutlet weak var extensionStauts: NSTextField!
    @IBOutlet weak var folderAccessStatus: NSTextField!
    @IBOutlet weak var accessFoldersTableView: NSTableView!
    @IBOutlet weak var showIconsCheckbox: NSButton!
    @IBOutlet weak var accessExternalVolumeCheckbox: NSButton!
    @IBOutlet weak var showIconsTip: NSButton!
    
    @IBAction func openSystemPreference(_ sender: Any) {
        FinderSync.FIFinderSyncController.showExtensionManagementInterface()
        openTipExtensionEnableWindow()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(onMonitorFinderExtension(_:)), name: Notification.Name("onMonitorFinderExtension"), object: nil)
    }
    
    @IBAction func grantHomeFolderAccess(_ sender: Any) {
        if XPCServiceManager.versionXPC() != XPC_VERSION {
            _ = NotifyManager.messageNotify(message: "The currently running background service version is not the latest, SzContext may not working properly. Please restart the computer to update.", inform: "", style: .informational)
            return
        }
        let addedFolder = BookmarkManager.allowFolder(for: FileManager.default.homeDirectoryForCurrentUser, note: NSLocalizedString("instruction.openFolder", comment: ""))
        os_log("SzContext: User add folder %@", addedFolder?.path ?? "")
        
        refreshState()
        DistributedNotificationCenter.default().post(name: Notification.Name("onUpdateMonitorFolder"), object: nil)
    }
    
    @IBAction func addAccessFolder(_ sender: Any) {
        _ = BookmarkManager.allowFolder(for: FileManager.default.homeDirectoryForCurrentUser, note: NSLocalizedString("instruction.openFolder", comment: ""))
        accessFolders = PreferenceManager.urlAccess()
        if String("/Volumes").isChildPath(of: accessFolders) {
            PreferenceManager.set(for: .accessExternalVolume, with: true)
        }
        refreshState()
    }
    
    @IBAction func removeAccessFolder(_ sender: Any) {
        guard accessFoldersTableView.selectedRow >= 0 else {
            return
        }
        let removedURL = accessFolders[accessFoldersTableView.selectedRow]
        var bookmark = PreferenceManager.bookmark()
        bookmark.removeValue(forKey: removedURL)
        
        PreferenceManager.set(for: .bookmarkAccessFolder, with: bookmark)
        accessFolders = PreferenceManager.urlAccess()
        if !String("/Volumes").isChildPath(of: accessFolders) {
            PreferenceManager.set(for: .accessExternalVolume, with: false)
        }
        refreshState()
    }
    
    @IBAction func accessExternalVolume(_ sender: Any) {
        let shouldAccessExternalVolume = accessExternalVolumeCheckbox.state == .on
        if shouldAccessExternalVolume {
            let monitorFolders = PreferenceManager.urlAccess()
            if !String("/Volumes/").isChildPath(of: monitorFolders){
                _ = BookmarkManager.allowFolder(for: URL(fileURLWithPath: "/Volumes/"), note: NSLocalizedString("instruction.openFolder", comment: ""))
            }
        } else {
            var bookmark = PreferenceManager.bookmark()
            bookmark.removeValue(forKey: URL(fileURLWithPath: "/Volumes/"))
            PreferenceManager.set(for: .bookmarkAccessFolder, with: bookmark)
        }
        PreferenceManager.set(for: .accessExternalVolume, with: shouldAccessExternalVolume)
        refreshState()
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
            NotificationCenter.default.post(name: Notification.Name("onMonitorStatus"), object: nil)
        }
        refreshState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accessFoldersTableView.delegate = self
        accessFoldersTableView.dataSource = self
        accessFoldersTableView.target = self
        refreshState()
        NotificationCenter.default.addObserver(self,selector: #selector(refreshState),name: Notification.Name("onMonitorStatus"),object: nil)
    }
    
    override func viewWillAppear() {
        refreshState()
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
    
    func reloadAccessFolderList() {
        accessFolders = PreferenceManager.urlAccess()
        accessFoldersTableView.reloadData()
    }
    
    @objc func onMonitorFinderExtension(_ notification:Notification) {
        closeTipExtensionEnableWindow()
        refreshState()
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
            folderAccessStatus.stringValue = "Folder access is granted"
        } else {
            folderAccessButton.image = NSImage(named: "NSStatusUnavailable")
            folderAccessStatus.stringValue = "Currently there is no folder granted."
        }
        
        showIconsCheckbox.state = PreferenceManager.bool(for: .showIconsOption) ? .on : .off
        accessExternalVolumeCheckbox.state = PreferenceManager.bool(for: .accessExternalVolume) ? .on : .off
        reloadAccessFolderList()
    }
}

extension PreferenceGeneralViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return accessFolders.count
    }
}

extension PreferenceGeneralViewController : NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if row < accessFolders.count {
            let item = accessFolders[row]

            if tableColumn == tableView.tableColumns[0] {
                text = item.path
                cellIdentifier = "accessFolderID"
            }

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
        }
        return nil
    }
}
