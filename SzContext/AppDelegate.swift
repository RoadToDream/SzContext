//
//  AppDelegate.swift
//  SzContext
//
//  Created by Jiawei Duan on 2018/8/25.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    class var serviceURL: URL {
        return Bundle.main.sharedSupportURL!.appendingPathComponent("SzContextService.app").absoluteURL
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let serviceBundleID = Bundle(url: AppDelegate.serviceURL)!.bundleIdentifier
        
        let apps = NSWorkspace.shared.runningApplications
        var runningApp: NSRunningApplication?
        for (_, app) in apps.enumerated() {
            if app.bundleIdentifier == serviceBundleID {
                runningApp = app
                break
            }
        }
        if runningApp == nil {
            do {
                try NSWorkspace.shared.launchApplication(at: AppDelegate.serviceURL, options: .async, configuration: [:])
            } catch {
                return
            }
        }
    }
}
