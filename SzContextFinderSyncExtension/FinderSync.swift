//
//  FinderSync.swift
//  SzContextFinderSyncExtension
//
//  Created by Jiawei Duan on 2018/8/25.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Cocoa
import FinderSync

let VSCodePath = URL(string: "file:///Applications/Visual%20Studio%20Code.app")
let TermPath = URL(string: "file:///System/Applications/Utilities/Terminal.app")

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
        openWithVSCodeItem.image = NSWorkspace.shared.icon(forFile: (VSCodePath?.path)!)

        openWithTermItem.target = self
        openWithTermItem.image = NSWorkspace.shared.icon(forFile: (TermPath?.path)!)
        
        return menu
    }
    
    @IBAction func openVSCodeAction(_ sender: AnyObject?) {
        let pb: NSPasteboard = {
            let bundleIdentifier = Bundle.main.bundleIdentifier!
            return NSPasteboard(name: NSPasteboard.Name(rawValue: "\(bundleIdentifier).pb"))
        }()
        var pbItems: [NSPasteboardItem] = []
        var urls = urlsToOpen
        urls.insert(VSCodePath!, at: 0)
        let urlStr = urls.map { $0.path }
        let joinedURLStr=urlStr.joined(separator: "\n")

        let item = NSPasteboardItem()
        item.setString(joinedURLStr, forType: .string)
        pbItems.append(item)

        pb.declareTypes([ .string ], owner: nil)
        pb.writeObjects(pbItems)
        NSPerformService("SzContextService", pb)
    }
    
    @IBAction func openTermAction(_ sender: AnyObject?) {

        let pb: NSPasteboard = {
            let bundleIdentifier = Bundle.main.bundleIdentifier!
            return NSPasteboard(name: NSPasteboard.Name(rawValue: "\(bundleIdentifier).pb"))
        }()
        var pbItems: [NSPasteboardItem] = []
        var urls = urlsToOpen
        urls.insert(TermPath!, at: 0)
        let urlStr = urls.map { $0.path }
        let joinedURLStr=urlStr.joined(separator: "\n")

        let item = NSPasteboardItem()
        item.setString(joinedURLStr, forType: .string)
        pbItems.append(item)

        pb.declareTypes([ .string ], owner: nil)
        pb.writeObjects(pbItems)
        NSPerformService("SzContextService", pb)
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

