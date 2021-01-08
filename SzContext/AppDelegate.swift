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
import LQ3C7Y6F8J_com_roadtodream_SzContextXPCHelper
import FinderSync

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindow : NSWindow?
    var tipWindowController : NSWindowController?
    let userDefaults = UserDefaults.init(suiteName: APP_GROUP)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainWindow = NSApplication.shared.mainWindow
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(onGrantScript(_:)), name: Notification.Name("onGrantScript"), object: nil,suspensionBehavior:.deliverImmediately)
        if PreferenceManager.bool(for: .enalbeScriptFolder) {
            DistributedNotificationCenter.default().post(name: Notification.Name("acceptGrantScript"), object: nil)
        }
        if !PreferenceManager.bool(for: .notFirstLaunch) {
            PreferenceManager.reset()
            PreferenceManager.set(for: .notFirstLaunch, with: true)
        }

        SMLoginItemSetEnabled(HELPER_BUNDLE as CFString, true)
    }
    
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication) -> Bool{
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    func enableShellScript() -> Bool {
        
        let helperScriptStr = """
#!/bin/sh
CMD="$1"
shift 1
open -a "$CMD" "$@"
"""
        var helperScriptFolderURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0]
        helperScriptFolderURL = helperScriptFolderURL.deletingLastPathComponent().appendingPathComponent(HELPER_BUNDLE)
        let helperScriptURL = helperScriptFolderURL.appendingPathComponent("execute.sh")
        if !FileManager.default.fileExists(atPath: helperScriptURL.path) {
            do {
                try helperScriptStr.write(to: helperScriptURL, atomically: true, encoding: String.Encoding.utf8)
                var attributes = [FileAttributeKey : Any]()
                attributes[.posixPermissions] = 0o777
                try FileManager.default.setAttributes(attributes, ofItemAtPath: helperScriptURL.path)
            } catch {
                return false
            }
        }
        return true
    }
    
    @objc func onGrantScript(_ notification:Notification) {
        var helperScriptFolderURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0]
        if BookmarkManager.isBookmarkEmpty(with: .bookmarkScriptFolder) {
            helperScriptFolderURL = helperScriptFolderURL.deletingLastPathComponent().appendingPathComponent(HELPER_BUNDLE)
            debugPrint(BookmarkManager.allowFolder(for: helperScriptFolderURL, with: .bookmarkScriptFolder, note: NSLocalizedString("instruction.scripFolder", comment: ""),window: mainWindow) as Any)
        }
        BookmarkManager.loadMainBookmarks(with: .bookmarkScriptFolder)
        bookmarkXPCUpdate()

        if enableShellScript() {
            _ = NotifyManager.messageNotify(message: NSLocalizedString("informational.scriptFolderAccess", comment: ""),inform: NSLocalizedString("informational.scriptFolderExplaination", comment: ""),style: .informational)
        } else {
            _ = NotifyManager.messageNotify(message: NSLocalizedString("informational.scriptFolderDenied", comment: ""),inform: NSLocalizedString("informational.scriptFolderExplaination", comment: ""),style: .informational)
        }
        PreferenceManager.set(for: .enalbeScriptFolder, with: false)
        NSApplication.shared.terminate(self)
    }

}
