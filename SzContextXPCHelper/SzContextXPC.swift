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
        BookmarkManager.manager.saveBookmarkFromMinimal(with: PreferenceManager.Key.bookmarkAccessFolder)
        BookmarkManager.manager.saveBookmarkFromMinimal(with: PreferenceManager.Key.bookmarkScriptFolder)
        reply("Proceed")
    }
    
    func openFiles(_ urlFiles: [URL], _ urlApp: URL, withReply reply: @escaping (String) -> Void){
        BookmarkManager.manager.loadHelperBookmarks(with: PreferenceManager.Key.bookmarkAccessFolder)
        BookmarkManager.manager.loadHelperBookmarks(with: PreferenceManager.Key.bookmarkScriptFolder)
        
        do {
            try NSWorkspace.shared.open(urlFiles, withApplicationAt: urlApp ,options: .default, configuration: [:])
        }
        catch {
            try! NSWorkspace.shared.open(NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.rtd.SzContext")!)
            
            let helperScriptFolderURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0].appendingPathComponent("execute.sh")
            let unixScript = try! NSUserUnixTask(url: helperScriptFolderURL)
            let argumentsArray = [urlApp]+urlFiles
            let argumentsStrArray = argumentsArray.map { $0.path }
            unixScript.execute(withArguments: argumentsStrArray, completionHandler: nil)
            reply("Error")
        }
        BookmarkManager.manager.stopAccessing(with: PreferenceManager.Key.bookmarkScriptFolder)
        BookmarkManager.manager.stopAccessing(with: PreferenceManager.Key.bookmarkAccessFolder)
        
        reply("Success")
    }
}
