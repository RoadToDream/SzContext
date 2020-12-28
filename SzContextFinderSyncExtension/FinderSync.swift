//
//  FinderSync.swift
//  SzContextFinderSyncExtension
//
//  Created by Jiawei Duan on 2018/8/25.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Cocoa
import FinderSync
import SzContextXPC


let VSCodePath = URL(string: "file:///Applications/Visual%20Studio%20Code.app")
let TermPath = [URL(string: "file:///System/Applications/Utilities/Terminal.app"),URL(string: "file:///Applications/Utilities/Terminal.app")]

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
        return NSWorkspace.shared.icon(forFile: (VSCodePath?.path)!)
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
        var urls = urlsToOpen
        urls.insert(VSCodePath!, at: 0)
        let joinedURLStr = urls.map { $0.path }.joined(separator: "\n")
        
        let connection = NSXPCConnection(serviceName: "com.rtd.SzContextXPC")
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()

        let service = connection.remoteObjectProxyWithErrorHandler { error in
            print("Received error:", error)
        } as? SzContextXPCProtocol

        service?.openFiles(joinedURLStr){ response in
            print(response)
        }
    }
    
    @IBAction func openTermAction(_ sender: AnyObject?) {
        var urls = urlsToOpen
        if FileManager.default.fileExists(atPath: TermPath[0]!.path){
            urls.insert(TermPath[0]!, at: 0)
        }
        else{
            urls.insert(TermPath[1]!, at: 0)
        }
        let joinedURLStr = urls.map { $0.path }.joined(separator: "\n")
        
        let connection = NSXPCConnection(serviceName: "com.rtd.SzContextXPC")
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            print("Received error:", error)
        } as? SzContextXPCProtocol

        service?.openFiles(joinedURLStr){ response in
            print(response)
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


