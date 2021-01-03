//
//  WindowController.swift
//  SzContext
//
//  Created by Jiawei Duan on 2018/8/27.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa

class MainWindowController: NSWindowController{
    override func windowDidLoad(){
        window?.isMovableByWindowBackground = true
    }
}

func enableFinderExtension(){
    let pipe = Pipe()
    let task = Process()
    task.launchPath = "/usr/bin/pluginkit"
    task.arguments = ["-e", "use", "-i", "com.rtd.SzContext.SzContextFinderSyncExtension"]
    task.standardOutput = pipe
    task.launch()
    let prefpaneUrl = URL(string: "file:///System/Library/PreferencePanes/Extensions.prefPane")!
    NSWorkspace.shared.open(prefpaneUrl)
}
