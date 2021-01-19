//
//  PreferenceCustomizeViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/3/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Cocoa

class PreferenceActionViewController: PreferenceViewController {

    let iconManager = IconCacheManager.init(name:"SzContext")
    var appsWithOption = PreferenceManager.appWithOption()
    
    var iconCache = [String:NSImage]()
    
    @IBOutlet weak var appWithOptionsTableView: NSTableView!
    @IBOutlet weak var appWithOptionsScrollView: NSScrollView!
    
    @IBAction func addApp(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.directoryURL = URL(string: "/Applications")
        
        openPanel.beginSheetModal(for: NSApplication.shared.mainWindow!){ [self](response) in
                if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                    if openPanel.url?.pathExtension == "app" {
                        appsWithOption.append(PreferenceManager.AppWithOptions.init(openPanel.url!, []))
                        PreferenceManager.set(for: .appWithOption, with: appsWithOption, updateIcon: true)
                        DispatchQueue.main.async {
                            iconManager.addPersistentIcon(appURL: openPanel.url!)
                        }
                        reloadAppList()
                    } else {
                        _ = NotifyManager.messageNotify(message: NSLocalizedString("informational.appAddError", comment: ""), inform: "", style: .informational)
                    }
            }
        }
    }
    @IBAction func removeApp(_ sender: Any) {
        guard appWithOptionsTableView.selectedRow >= 0 else {
            return
        }
        appsWithOption.remove(at: appWithOptionsTableView.selectedRow)
        PreferenceManager.set(for: .appWithOption, with: appsWithOption, updateIcon: false)
        reloadAppList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appWithOptionsTableView.delegate = self
        appWithOptionsTableView.dataSource = self
        appWithOptionsTableView.target = self
        appWithOptionsTableView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: "com.roadtodream.szcontext.appwithoptions")])
        
        if #available(macOS 11.0, *) {
            appWithOptionsScrollView.layer?.masksToBounds = true
            appWithOptionsScrollView.layer?.cornerRadius = 10
            appWithOptionsScrollView.borderType = .noBorder
            appWithOptionsTableView.style = .inset
        }
        iconCache = iconManager.fetchPersistentIcon()
        
        NotificationCenter.default.addObserver(self,selector: #selector(iconCacheChanges),name: NSNotification.Name(rawValue: "NSPersistentStoreRemoteChangeNotification"),object: iconManager.persistentContainer.persistentStoreCoordinator)

    }
    
    override func viewWillAppear() {
        reloadAppList()
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    override func viewDidDisappear() {
        DistributedNotificationCenter.default().removeObserver(self)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func reloadAppList() {
        appsWithOption = PreferenceManager.appWithOption()
        appWithOptionsTableView.reloadData()
    }
    
    @objc func iconCacheChanges() {
        iconCache = iconManager.fetchPersistentIcon()
    }
    
}


extension PreferenceActionViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return appsWithOption.count
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let draggedData = appsWithOption[row]
        return draggedData
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
                return .move
            }
            return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        let appWithOptionPasteboardType = NSPasteboard.PasteboardType.init("com.roadtodream.szcontext.appwithoptions")
        guard
            let item = info.draggingPasteboard.pasteboardItems?.first,
            let appWithOption = PreferenceManager.AppWithOptions(pasteboardPropertyList: item.data(forType: appWithOptionPasteboardType) as Any, ofType: appWithOptionPasteboardType),
            let originalRow = appsWithOption.firstIndex(where: {$0.app == appWithOption.app})
            else {
                return false
        }
        var newRow = row
        if originalRow < newRow {
            newRow = row - 1
        }
        tableView.beginUpdates()
        tableView.moveRow(at: originalRow, to: newRow)
        tableView.endUpdates()
        let removed = appsWithOption.remove(at: originalRow)
        appsWithOption.insert(removed, at: newRow)
        PreferenceManager.set(for: .appWithOption, with: appsWithOption, updateIcon: false)
        return true
    }
}


extension PreferenceActionViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        if row < appsWithOption.count {
            let item = appsWithOption[row]

            if tableColumn == tableView.tableColumns[0] {
                text = item.app.lastPathComponent
                image = NSWorkspace.shared.icon(forFile: item.app.path)
                cellIdentifier = "appWithOptionID"
            }

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                cell.imageView?.image = image
                return cell
            }
        }
        return nil
    }
}
