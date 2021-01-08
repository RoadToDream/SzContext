//
//  PreferenceCustomizeViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/3/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Cocoa

class PreferenceActionViewController: PreferenceViewController {

    var appsWithOption = PreferenceManager.appWithOption(for: .appWithOption)
    
    @IBOutlet weak var appWithOptionsTableView: NSTableView!
    
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
                        PreferenceManager.set(for: .appWithOption, with: appsWithOption)
                        reloadAppList()
                    } else {
                        _ = NotifyManager.messageNotify(message: "Only Application is supported", inform: "", style: .informational)
                    }
            }
        }
    }
    @IBAction func removeApp(_ sender: Any) {
        guard appWithOptionsTableView.selectedRow >= 0 else {
            return
        }
        appsWithOption.remove(at: appWithOptionsTableView.selectedRow)
        PreferenceManager.set(for: .appWithOption, with: appsWithOption)
        reloadAppList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appWithOptionsTableView.delegate = self
        appWithOptionsTableView.dataSource = self
        appWithOptionsTableView.target = self
    }
    
    override func viewWillAppear() {
        reloadAppList()
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    func reloadAppList() {
        appsWithOption = PreferenceManager.appWithOption(for: .appWithOption)
        appWithOptionsTableView.reloadData()
    }
}


extension PreferenceActionViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return appsWithOption.count
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
                text = item.app().lastPathComponent
                cellIdentifier = "appWithOptionID"
            }

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                cell.imageView?.image = image ?? nil
                return cell
            }
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        
    }
}
