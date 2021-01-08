//
//  PreferenceFinderViewController.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/5/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation

import Cocoa

class PreferenceFinderViewController: PreferenceViewController {

    var bookmarkAccessFolderDict = PreferenceManager.bookmark(for: .bookmarkAccessFolder)
    var bookmarkAccessFolderArray = Array(PreferenceManager.bookmark(for: .bookmarkAccessFolder).keys)
    
    @IBOutlet weak var bookmarkAccessFolderTableView: NSTableView!
    
    @IBAction func addDirectory(_ sender: Any) {
        _ = BookmarkManager.allowFolder(for: URL(string: "~/"), with: .bookmarkAccessFolder, note: NSLocalizedString("instruction.openFolder", comment: ""))
        bookmarkXPCUpdate()
        reloadAppList()
        DistributedNotificationCenter.default().post(name: Notification.Name("folderObserver"), object: nil)
    }
    @IBAction func removeDirectory(_ sender: Any) {
        guard bookmarkAccessFolderTableView.selectedRow >= 0 else {
            return
        }
        let url = bookmarkAccessFolderArray[bookmarkAccessFolderTableView.selectedRow]
        bookmarkAccessFolderDict.removeValue(forKey: url)
        bookmarkAccessFolderArray.remove(at: bookmarkAccessFolderTableView.selectedRow)
        reloadAppList()
        PreferenceManager.set(for: .bookmarkAccessFolder, with: bookmarkAccessFolderDict)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookmarkAccessFolderTableView.delegate = self
        bookmarkAccessFolderTableView.dataSource = self
        bookmarkAccessFolderTableView.target = self
    }
    
    override func viewWillAppear() {
        reloadAppList()
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    func reloadAppList() {
        bookmarkAccessFolderArray = Array(PreferenceManager.bookmark(for: .bookmarkAccessFolder).keys)
        bookmarkAccessFolderTableView.reloadData()
    }
}


extension PreferenceFinderViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return bookmarkAccessFolderArray.count
    }
}


extension PreferenceFinderViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        if row < bookmarkAccessFolderArray.count {
            let item = bookmarkAccessFolderArray[row]

            if tableColumn == tableView.tableColumns[0] {
                text = item.path
                cellIdentifier = "bookmarkAccessFolderID"
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


