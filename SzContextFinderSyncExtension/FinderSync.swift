//
//  FinderSync.swift
//  SzContextFinderSyncExtension
//
//  Created by Jiawei Duan on 2018/8/25.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Cocoa
import FinderSync
import LQ3C7Y6F8J_com_roadtodream_SzContextXPCHelper
import OSLog

class FinderSync: FIFinderSync {
    let iconManager = IconCacheManager.init(name:"SzContext")
    var appsWithOption = PreferenceManager.appWithOption()
    var showIconsOption = PreferenceManager.bool(for: .showIconsOption)
    var appearFolderURL = [URL(fileURLWithPath: "/"),URL(fileURLWithPath: "/Volumes/")]
    var iconCache = [String:NSImage]()
    var showOpenRecentOption = PreferenceManager.bool(for: .showOpenRecent)
    
    override init() {
        super.init()
        DistributedNotificationCenter.default().post(name: Notification.Name("onMonitorFinderExtension"), object: nil)
        FIFinderSyncController.default().directoryURLs = Set(appearFolderURL)
        if let volumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: .skipHiddenVolumes) {
            FIFinderSyncController.default().directoryURLs = FIFinderSyncController.default().directoryURLs.union(Set(volumes))
        }
        iconCache = iconManager.fetchPersistentIcon()
        NotificationCenter.default.addObserver(self,selector: #selector(iconCacheChanges),name: NSNotification.Name(rawValue: "NSPersistentStoreRemoteChangeNotification"),object: iconManager.persistentContainer.persistentStoreCoordinator)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(updateMonitorFolder), name: Notification.Name("onUpdateMonitorFolder"), object: nil)
        let diskNotificationCenter = NSWorkspace.shared.notificationCenter
        diskNotificationCenter.addObserver(forName: NSWorkspace.didMountNotification, object: nil, queue: .main) {
            (notification) in
            if PreferenceManager.bool(for: .accessExternalVolume) {
                if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                    FIFinderSyncController.default().directoryURLs.insert(volumeURL)
                }
            }
        }
        diskNotificationCenter.addObserver(forName: NSWorkspace.didUnmountNotification, object: nil, queue: .main) {
            (notification) in
            if PreferenceManager.bool(for: .accessExternalVolume) {
                if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                    FIFinderSyncController.default().directoryURLs.remove(volumeURL)
                }
            }
        }
    }
    
    override var toolbarItemName: String {
        return "SzContext"
    }
    
    override var toolbarItemToolTip: String {
        return "Open with SzContext"
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "SzContextIcon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        
        let menu = NSMenu(title: "")
        let urls = urlsToOpen
        if shouldAppear(files: urls) {
            showOpenRecentOption = PreferenceManager.bool(for: .showOpenRecent)
            if showOpenRecentOption {
                let executeAppleScriptItem = NSMenuItem(title: "Goto last open", action: #selector(executeApplescript(_:)), keyEquivalent: "")
                executeAppleScriptItem.image=NSImage(named: NSImage.Name("NSGoForwardTemplate"));
                menu.addItem(executeAppleScriptItem)
            }
            appsWithOption = PreferenceManager.appWithOption()
            showIconsOption = PreferenceManager.bool(for: .showIconsOption)
            for (index,appWithOption) in appsWithOption.enumerated() {
                let itemStr = NSLocalizedString("extension.openWithPre", comment: "")+NSString(string: appWithOption.app.lastPathComponent).deletingPathExtension+NSLocalizedString("extension.openWithPost", comment: "")
                let openWithItem = NSMenuItem(title: itemStr, action: #selector(openAction(_:)), keyEquivalent: "")
                openWithItem.tag = index
                openWithItem.target = self
                if showIconsOption {
                    openWithItem.image = iconCache[appWithOption.app.path]
                }
                menu.addItem(openWithItem)
            }
        }
        return menu
    }
    @objc func openAction(_ sender: NSMenuItem) {
        let urls = urlsToOpen
        let tag = sender.tag
        let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()

        let service = connection.remoteObjectProxyWithErrorHandler { error in
            os_log("SzContext Sync Extension: XPC connection creation error %@", error.localizedDescription)
        } as? SzContextXPCProtocol

        service?.openFiles(urlFiles: urls, urlApp: appsWithOption[tag].app){ response in
            os_log("%@", response)
        }
    }
    
    @objc func executeApplescript(_ sender: NSMenuItem) {
        let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()

        let service = connection.remoteObjectProxyWithErrorHandler { error in
            os_log("SzContext Sync Extension: XPC connection creation error %@", error.localizedDescription)
        } as? SzContextXPCProtocol

        service?.executeApplescript(name: "finderGoto.scpt"){ response in
            os_log("%@", response)
        }
    }
    
    private var urlsToOpen: [URL] {
        get {

            guard let target = FIFinderSyncController.default().targetedURL() else {
                return []
            }
            
            guard let items = FIFinderSyncController.default().selectedItemURLs() else {
                return []
            }
            if items.count > 0 {
                return items
            } else {
                return [ target ]
            }
        }
    }
    
    func shouldAppear(files: [URL]) -> Bool {
        for file in files {
            if !file.path.isChildPath(of: appearFolderURL) {
                return false
            }
        }
        return true
    }
    
    @objc func iconCacheChanges() {
        iconCache = iconManager.fetchPersistentIcon()
    }
    
    @objc func updateMonitorFolder() {
        appearFolderURL = PreferenceManager.urlAccess()
    }
    
}


