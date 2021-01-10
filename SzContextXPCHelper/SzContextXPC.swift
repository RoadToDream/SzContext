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
        reply("SzContext XPC service: Bookmark successfully updated")
    }
    
    func openFiles(_ urlFiles: [URL], _ urlApp: URL, withReply reply: @escaping (String) -> Void){
        _ = BookmarkManager.loadHelperBookmarks(with: .bookmarkAccessFolder)
        for urlFile in urlFiles {
            do {
                if urlFile.hasDirectoryPath {
                    _ = try FileManager.default.contentsOfDirectory(atPath: urlFile.path)
                }
            } catch  {
                reply("SzContext XPC service: Error open files")
            }
        }
        let configOpen = NSWorkspace.OpenConfiguration()
        configOpen.promptsUserIfNeeded = false
        if urlFiles.count == 1 && !urlFiles[0].hasDirectoryPath{
            if isTerminal(appBundleID: Bundle(path: urlApp.path)?.bundleIdentifier) {
                NSWorkspace.shared.open([urlFiles[0].deletingLastPathComponent()], withApplicationAt: urlApp, configuration: configOpen)
            } else {
                NSWorkspace.shared.open(urlFiles, withApplicationAt: urlApp, configuration: configOpen)
            }
        }
        else {
            NSWorkspace.shared.open(urlFiles, withApplicationAt: urlApp, configuration: configOpen)
        }
        BookmarkManager.stopAccessing(with: .bookmarkAccessFolder)
        reply("SzContext XPC service: Success open files")
    }
    
    func isTerminal(appBundleID: String?) -> Bool {
        if appBundleID != nil {
            for termID in terminalID.allCases {
                if appBundleID == termID.rawValue {
                    return true
                }
            }
        }
        return false
    }
    
}
