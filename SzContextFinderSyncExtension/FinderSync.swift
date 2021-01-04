//
//  FinderSync.swift
//  SzContextFinderSyncExtension
//
//  Created by Jiawei Duan on 2018/8/25.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Cocoa
import FinderSync
import LQ3C7Y6F8J_com_rtd_SzContextXPCHelper


class FinderSync: FIFinderSync {
    
    var curFolderURL = URL(fileURLWithPath: "/")

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [self.curFolderURL]
    }
    
    
    override var toolbarItemName: String {
        return "Open VS Code"
    }
    
    override var toolbarItemToolTip: String {
        return "Open VS Code for selected items"
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "VSCodeIcon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        let openWithVSCodeItem = menu.addItem(withTitle: "Open in VS Code", action: #selector(openVSCodeAction(_:)), keyEquivalent: "")
        let openWithTermItem = menu.addItem(withTitle: "Open in Terminal", action: #selector(openTermAction(_:)), keyEquivalent: "")
        openWithVSCodeItem.target = self
        openWithVSCodeItem.image = NSImage(named: "VSCodeIcon")

        openWithTermItem.target = self
        openWithTermItem.image = NSImage(named: "TermIcon")
        
        
        return menu
    }
    
    @IBAction func openVSCodeAction(_ sender: AnyObject?) {
        let urls = urlsToOpen

        let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()

        let service = connection.remoteObjectProxyWithErrorHandler { error in
            debugPrint("Received error:", error)
        } as? SzContextXPCProtocol

        service?.openFiles(urls, NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.microsoft.VSCode")!){ response in
            debugPrint(response)
        }
    }
    
    @IBAction func openTermAction(_ sender: AnyObject?) {
        let urls = urlsToOpen

        let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()

        let service = connection.remoteObjectProxyWithErrorHandler { error in
            debugPrint("Received error:", error)
        } as? SzContextXPCProtocol

        service?.openFiles(urls, NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal")!){ response in
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


