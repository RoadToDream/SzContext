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
import ServiceManagement

class PreferenceGeneralViewController: PreferenceViewController {
    
    var tipExtensionEnableWindowController : NSWindowController?
    var accessFolders = PreferenceManager.urlAccess()
    
    @IBOutlet weak var extensionButton: NSButton!
    @IBOutlet weak var folderAccessButton: NSButton!
    @IBOutlet weak var extensionStauts: NSTextField!
    @IBOutlet weak var folderAccessStatus: NSTextField!
    @IBOutlet weak var accessFoldersTableView: NSTableView!
    @IBOutlet weak var accessFolderScrollView: NSScrollView!
    @IBOutlet weak var showIconsCheckbox: NSButton!
    @IBOutlet weak var accessExternalVolumeCheckbox: NSButton!
    @IBOutlet weak var showIconsTipButton: NSButton!
    
    @IBAction func openSystemPreference(_ sender: Any) {
        FinderSync.FIFinderSyncController.showExtensionManagementInterface()
        openTipExtensionEnableWindow()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(onMonitorFinderExtension(_:)), name: Notification.Name("onMonitorFinderExtension"), object: nil,suspensionBehavior:.deliverImmediately)
    }
    
    @IBAction func addAccessFolder(_ sender: Any) {
        if XPCServiceManager.versionXPC() != XPC_VERSION {
            SMLoginItemSetEnabled(HELPER_BUNDLE as CFString, false)
            SMLoginItemSetEnabled(HELPER_BUNDLE as CFString, true)
        }
        let addedFolder = BookmarkManager.allowFolder(for: FileManager.default.homeDirectoryForCurrentUser, note: NSLocalizedString("instruction.openFolder", comment: ""))
        os_log("SzContext: User add folder %@", addedFolder?.path ?? "")
        accessFolders = PreferenceManager.urlAccess()
        if String("/Volumes").isChildPath(of: accessFolders) {
            PreferenceManager.set(for: .accessExternalVolume, with: true)
        }
        refreshState()
        DistributedNotificationCenter.default().post(name: Notification.Name("onUpdateMonitorFolder"), object: nil)
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
        showIconsTipPopover.show(relativeTo: showIconsTipButton.visibleRect, of: showIconsTipButton, preferredEdge: NSRectEdge.maxX)
    }
    
    @IBAction func resetPreference(_ sender: Any) {
        if NotifyManager.messageNotify(message: NSLocalizedString("warning.resetPreference", comment: ""), inform: "", style: .warning) {
            PreferenceManager.reset()
            refreshState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshState), name: NSNotification.Name("refreshState"), object: nil)
        
        accessFoldersTableView.delegate = self
        accessFoldersTableView.dataSource = self
        accessFoldersTableView.target = self
        if #available(macOS 11.0, *) {
            accessFolderScrollView.layer?.masksToBounds = true
            accessFolderScrollView.layer?.cornerRadius = 10
            accessFolderScrollView.borderType = .noBorder
            accessFoldersTableView.style = .inset
        }
        
        refreshState()
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
            extensionStauts.stringValue = NSLocalizedString("general.extensionEnabled", comment: "")
        } else {
            extensionButton.image = NSImage(named: "NSStatusUnavailable")
            extensionStauts.stringValue = NSLocalizedString("general.extensionNotEnabled", comment: "")
        }
        if !BookmarkManager.isBookmarkEmpty(with: PreferenceManager.Key.urlAccessFolder) {
            folderAccessButton.image = NSImage(named: "NSStatusAvailable")
            folderAccessStatus.stringValue = NSLocalizedString("general.accessFolderGranted", comment: "")
        } else {
            folderAccessButton.image = NSImage(named: "NSStatusUnavailable")
            folderAccessStatus.stringValue = NSLocalizedString("general.accessFolderNotGranted", comment: "")
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
