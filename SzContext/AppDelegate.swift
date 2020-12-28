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


    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication) -> Bool{
        return true
    }
}
