//
//  WindowController.swift
//  SzContext
//
//  Created by Jiawei Duan on 2018/8/27.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa
import FinderSync

class MainWindowController: NSWindowController, NSWindowDelegate{
    var tipWindowController : NSWindowController?
    
    override func windowDidLoad(){
        window?.isMovableByWindowBackground = true
    }
    
    func windowDidBecomeMain(_ notification: Notification) {
        if !FinderSync.FIFinderSyncController.isExtensionEnabled {
            FinderSync.FIFinderSyncController.showExtensionManagementInterface()
            openTipWindow()
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(onMonitorFinderExtension(_:)), name: Notification.Name("onMonitorFinderExtension"), object: nil,suspensionBehavior:.deliverImmediately)
        }
    }
    
    func openTipWindow(){
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        tipWindowController = (storyboard.instantiateController(withIdentifier: "extensionTipWindowControllerID") as! NSWindowController)
        
        tipWindowController?.showWindow(self)
        tipWindowController?.window?.level = .floating
    }
    
    func closeTipWindow(){
        if ((tipWindowController?.isWindowLoaded) != nil) {
            tipWindowController!.close()
        }
    }
    
    @objc func onMonitorFinderExtension(_ notification:Notification) {
        closeTipWindow()
    }
}
