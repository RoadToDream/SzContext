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
    
    func updateBookmarks(_ bookmarkData: [Data], withReply reply: @escaping (String) -> Void) {
        var securityBookmark = [URL:Data]()
        for bookmark in bookmarkData {
            var stale = false
            let restoredUrl = try! URL.init(resolvingBookmarkData: bookmark, options: NSURL.BookmarkResolutionOptions.withoutUI, relativeTo: nil, bookmarkDataIsStale: &stale)
            let data = try! restoredUrl.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            securityBookmark.updateValue(data, forKey: restoredUrl)
        }
        guard let bookmarkURL = BookmarkManager.manager.getBookmarkDatabaseURL() else {
            return
        }
        let bookmardData = try! NSKeyedArchiver.archivedData(withRootObject: securityBookmark, requiringSecureCoding: false)
        try! bookmardData.write(to: bookmarkURL)
        
        reply("Proceed")
    }
    
    func openFiles(_ urlFiles: [URL], _ urlApp: URL, withReply reply: @escaping (String) -> Void){
        BookmarkManager.manager.loadBookmarks()
        do {
            try NSWorkspace.shared.open(urlFiles, withApplicationAt: urlApp ,options: .default, configuration: [:])
        }
        catch {
            let helperScriptFolderURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0].appendingPathComponent("execute.sh")
            let unixScript = try! NSUserUnixTask(url: helperScriptFolderURL)
            let argumentsArray = [urlApp]+urlFiles
            let argumentsStrArray = argumentsArray.map { $0.path }
            unixScript.execute(withArguments: argumentsStrArray, completionHandler: nil)
            reply("Error")
        }
        BookmarkManager.manager.stopAccessing()
        reply("Success")
    }
}
