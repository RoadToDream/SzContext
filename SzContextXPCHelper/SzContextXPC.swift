//
//  SzContextXPC.m
//  SzContextXPC
//
//  Created by Jiawei Duan on 12/27/20.
//  Copyright © 2020 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa

class SzContextXPC: NSObject, SzContextXPCProtocol {
    
    func updateBookmarks(withReply reply: @escaping (String) -> Void) {
        BookmarkManager.saveBookmarkFromMinimal(with: .bookmarkAccessFolder)
        BookmarkManager.saveBookmarkFromMinimal(with: .bookmarkScriptFolder)
        BookmarkManager.stopAccessing(with: .bookmarkAccessFolder)
        BookmarkManager.stopAccessing(with: .bookmarkScriptFolder)
        _ = BookmarkManager.loadHelperBookmarks(with: .bookmarkAccessFolder)
        _ = BookmarkManager.loadHelperBookmarks(with: .bookmarkScriptFolder)
        reply("Proceed")
    }
    
    func openFiles(_ urlFiles: [URL], _ urlApp: URL, withReply reply: @escaping (String) -> Void){
        _ = BookmarkManager.loadHelperBookmarks(with: .bookmarkAccessFolder)
        let configOpen = NSWorkspace.OpenConfiguration()
        configOpen.promptsUserIfNeeded = false
        NSWorkspace.shared.open(urlFiles, withApplicationAt: urlApp, configuration: configOpen){ [self] app,error in
            if error != nil {
                if !BookmarkManager.loadHelperBookmarks(with: .bookmarkScriptFolder) {
                    PreferenceManager.set(for: .enalbeScriptFolder, with: true)
                    DistributedNotificationCenter.default().addObserver(self, selector: #selector(postScriptGrand(_:)), name: Notification.Name("acceptGrantScript"), object: nil,suspensionBehavior:.deliverImmediately)
                    NSWorkspace.shared.open(NSWorkspace.shared.urlForApplication(withBundleIdentifier: MAIN_BUNDLE)! ,configuration: configOpen, completionHandler: nil)
                } else {
                    let helperScriptFolderURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0].appendingPathComponent("execute.sh")
                    do {
                        let unixScript = try NSUserUnixTask(url: helperScriptFolderURL)
                        let argumentsArray = [urlApp]+urlFiles
                        let argumentsStrArray = argumentsArray.map { $0.path }
                        unixScript.execute(withArguments: argumentsStrArray, completionHandler: nil)
                    } catch {
                        _ = NotifyManager.messageNotify(message: "Script file does not exist, you may not use SzContext in this folder", inform: "", style: .informational)
                    }
                    BookmarkManager.stopAccessing(with: .bookmarkScriptFolder)
                }
                reply("Using Script")
            } else {
                BookmarkManager.stopAccessing(with: .bookmarkAccessFolder)
                reply("Using Bookmark")
            }
        }

    }
    
    @objc func postScriptGrand(_ notification:Notification) {
        DistributedNotificationCenter.default().post(name: Notification.Name("onGrantScript"), object: nil)
    }
    
}
