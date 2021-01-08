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
    
    let userDefaults = UserDefaults.init(suiteName: APP_GROUP)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

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

}
