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
    var firstStartUpWindowController : NSWindowController?
    
    var mainWindow : NSWindow?
    let userDefaults = UserDefaults.init(suiteName: APP_GROUP)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        SMLoginItemSetEnabled(HELPER_BUNDLE as CFString, false)
        SMLoginItemSetEnabled(HELPER_BUNDLE as CFString, true)
        mainWindow = NSApplication.shared.mainWindow
        if !PreferenceManager.bool(for: .notFirstLaunch) {
            PreferenceManager.reset()
            PreferenceManager.set(for: .notFirstLaunch, with: true)
            openFirstStartUpWindow()
        }

        BookmarkManager.loadMainBookmarks(with: PreferenceManager.Key.bookmarkAccessFolder)
        bookmarkXPCUpdate()
        
    }
    
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication) -> Bool{
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {

    }
    
    func openFirstStartUpWindow(){
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        firstStartUpWindowController = (storyboard.instantiateController(withIdentifier: "tipFirstStartUpWindowControllerID") as! NSWindowController)
        firstStartUpWindowController?.showWindow(self)
        firstStartUpWindowController?.window?.level = .floating
    }
    
}
