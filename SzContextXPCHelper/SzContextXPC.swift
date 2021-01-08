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
        enableShellScript()
        
        _ = BookmarkManager.loadHelperBookmarks(with: .bookmarkAccessFolder)
        let configOpen = NSWorkspace.OpenConfiguration()
        configOpen.promptsUserIfNeeded = false
        NSWorkspace.shared.open(urlFiles, withApplicationAt: urlApp, configuration: configOpen){ app,error in
            if error != nil {
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
    func enableShellScript() -> Bool {
        var helperScriptFolderURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0]
        let helperScriptURL = helperScriptFolderURL.appendingPathComponent("execute.sh")
        if !FileManager.default.fileExists(atPath: helperScriptURL.path) {
            let helperScriptStr = """
    #!/bin/sh
    CMD="$1"
    shift 1
    open -a "$CMD" "$@"
    """
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
}
