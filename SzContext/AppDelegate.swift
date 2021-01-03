//
//  AppDelegate.swift
//  SzContext
//
//  Created by Jiawei Duan on 2018/8/25.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//
import Foundation
import Cocoa
import ServiceManagement
import LQ3C7Y6F8J_com_rtd_SzContextXPCHelper
import FinderSync

extension UserDefaults {
    @objc dynamic var isExtensionEnabled: Int {
        return integer(forKey: "extensionEnabled")
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var tipWindowController : NSWindowController?
    let defaults = UserDefaults.init(suiteName: APP_GROUP)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        SMLoginItemSetEnabled(MACH_SERVICE as CFString, true)
        SMLoginItemSetEnabled(MACH_SERVICE as CFString, false)
        SMLoginItemSetEnabled(MACH_SERVICE as CFString, true)
        let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            debugPrint("Received error:", error)
        } as? SzContextXPCProtocol
        
        var helperScriptFolderURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0]
        if BookmarkManager.manager.isBookmarkEmpty() {
            helperScriptFolderURL = helperScriptFolderURL.deletingLastPathComponent().appendingPathComponent(HELPER_BUNDLE)
            debugPrint(BookmarkManager.manager.allowFolder(url: helperScriptFolderURL) as Any)
            debugPrint(BookmarkManager.manager.allowFolder(url: URL(string: "~/")) as Any)
        }
        let helperScriptStr = """
#!/bin/sh
CMD="$1"
shift 1
open -a "$CMD" "$@"
"""
        
        let helperScriptURL = helperScriptFolderURL.appendingPathComponent("execute.sh")
        do {
            try helperScriptStr.write(to: helperScriptURL, atomically: true, encoding: String.Encoding.utf8)
            var attributes = [FileAttributeKey : Any]()
            attributes[.posixPermissions] = 0o777
            try FileManager.default.setAttributes(attributes, ofItemAtPath: helperScriptURL.path)
        } catch {
            debugPrint("Failed to write script")
        }
        
        
        let fileBookmarks=BookmarkManager.manager.getMinimalBookmark()

        
        service?.updateBookmarks(fileBookmarks){ response in
            debugPrint(response)
        }
        

        if !FinderSync.FIFinderSyncController.isExtensionEnabled {
            defaults?.setValue(false, forKey: "extensionEnabled")
            defaults?.synchronize()
            FinderSync.FIFinderSyncController.showExtensionManagementInterface()
            openTipWindow()
//            sleep(2)
            tipWindowController?.close()
        }
    }
    
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication) -> Bool{
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
    }
    
    func openTipWindow(){
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        tipWindowController = (storyboard.instantiateController(withIdentifier: "tipWindow") as! NSWindowController)
        tipWindowController!.showWindow(self)
    }
    
}
