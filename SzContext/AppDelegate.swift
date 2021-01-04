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


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var tipWindowController : NSWindowController?
    let userDefaults = UserDefaults.init(suiteName: APP_GROUP)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        SMLoginItemSetEnabled(MACH_SERVICE as CFString, true)
        
        var helperScriptFolderURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0]
        if BookmarkManager.manager.isBookmarkEmpty(with: PreferenceManager.Key.bookmarkAccessFolder) {
            debugPrint(BookmarkManager.manager.allowFolder(for: URL(string: "~/"), with: PreferenceManager.Key.bookmarkAccessFolder) as Any)
        }
        if BookmarkManager.manager.isBookmarkEmpty(with: PreferenceManager.Key.bookmarkScriptFolder) {
            helperScriptFolderURL = helperScriptFolderURL.deletingLastPathComponent().appendingPathComponent(HELPER_BUNDLE)
            debugPrint(BookmarkManager.manager.allowFolder(for: helperScriptFolderURL, with: PreferenceManager.Key.bookmarkScriptFolder) as Any)
        }
        
        BookmarkManager.manager.loadMainBookmarks(with: PreferenceManager.Key.bookmarkAccessFolder)
        BookmarkManager.manager.loadMainBookmarks(with: PreferenceManager.Key.bookmarkScriptFolder)
        
        enableShellScript()
        
        let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            debugPrint("Received error:", error)
        } as? SzContextXPCProtocol
        service?.updateBookmarks(){ response in
            debugPrint(response)
        }
        
        

        if !FinderSync.FIFinderSyncController.isExtensionEnabled {
            FinderSync.FIFinderSyncController.showExtensionManagementInterface()
            openTipWindow()
            enableMonitorExtension()
        }
        
        
        
    }
    
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication) -> Bool{
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
    }
    
    func enableShellScript() {
        
        let helperScriptStr = """
#!/bin/sh
CMD="$1"
shift 1
open -a "$CMD" "$@"
"""
        var helperScriptFolderURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0]
        helperScriptFolderURL = helperScriptFolderURL.deletingLastPathComponent().appendingPathComponent(HELPER_BUNDLE)
        let helperScriptURL = helperScriptFolderURL.appendingPathComponent("execute.sh")
        do {
            try helperScriptStr.write(to: helperScriptURL, atomically: true, encoding: String.Encoding.utf8)
            var attributes = [FileAttributeKey : Any]()
            attributes[.posixPermissions] = 0o777
            try FileManager.default.setAttributes(attributes, ofItemAtPath: helperScriptURL.path)
        } catch {
            debugPrint("Failed to write script")
        }
        
    }
    
    func enableMonitorExtension() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            if FIFinderSyncController.isExtensionEnabled == true {
                closeTipWindow()
                timer.invalidate()
            }
        }
    }
    
    func openTipWindow(){
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        tipWindowController = (storyboard.instantiateController(withIdentifier: "extensionTipWindowController") as! NSWindowController)
        tipWindowController!.showWindow(self)
    }
    func closeTipWindow(){
        if ((tipWindowController?.isWindowLoaded) != nil) {
            tipWindowController!.close()
        }
    }
}
