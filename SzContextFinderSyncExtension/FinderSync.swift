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

extension String {
    func isChildPath(of paths: [String]) -> Bool {
        for path in paths {
            if self.count >= path.count {
                let monitorComponents = URL(fileURLWithPath: path).pathComponents
                if monitorComponents == Array(URL(fileURLWithPath: self).pathComponents.prefix(monitorComponents.count)) {
                    return true
                }
            }
        }
        return false
    }
}

class FinderSync: FIFinderSync {
    
    var monitorFolders = PreferenceManager.url(for: .urlAccessFolder)
    var appsWithOption = PreferenceManager.appWithOption(for: .appWithOption)
    var showIconsOption = PreferenceManager.bool(for: .showIconsOption)
    var appearFolderURL = [URL(fileURLWithPath: "/"),URL(fileURLWithPath: "/Volumes/")]
    
    override init() {
        super.init()
        DistributedNotificationCenter.default().post(name: Notification.Name("onMonitorFinderExtension"), object: nil)
        FIFinderSyncController.default().directoryURLs = Set(appearFolderURL)
    }
    
    
    override var toolbarItemName: String {
        return "SzContext"
    }
    
    override var toolbarItemToolTip: String {
        return "Open with SzContexts"
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "SzContextIcon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        monitorFolders = PreferenceManager.url(for: .urlAccessFolder)
        let urls = urlsToOpen
        if urls[0].path.isChildPath(of: monitorFolders) {
            appsWithOption = PreferenceManager.appWithOption(for: .appWithOption)
            showIconsOption = PreferenceManager.bool(for: .showIconsOption)
            for (index,appWithOption) in appsWithOption.enumerated() {
                let itemStr = NSLocalizedString("extension.openWithPre", comment: "")+NSString(string: appWithOption.app().lastPathComponent).deletingPathExtension+NSLocalizedString("extension.openWithPost", comment: "")
                let openWithItem = NSMenuItem(title: itemStr, action: #selector(openAction(_:)), keyEquivalent: "")
                openWithItem.tag = index
                openWithItem.target = self
                if showIconsOption {
                    openWithItem.image = NSImage(named: appWithOption.app().lastPathComponent)
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
            debugPrint("Received error:", error)
        } as? SzContextXPCProtocol

        service?.openFiles(urls, appsWithOption[tag].app()){ response in
            debugPrint(response)
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
}


