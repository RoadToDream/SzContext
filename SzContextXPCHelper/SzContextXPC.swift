//
//  SzContextXPC.m
//  SzContextXPC
//
//  Created by Jiawei Duan on 12/27/20.
//  Copyright © 2020 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa
import AppleScriptObjC

class SzContextXPC: NSObject, SzContextXPCProtocol {
    
    func checkVersion(withReply reply: @escaping (String) -> Void) {
        reply(PreferenceManager.xpcVersion())
    }
    
    func openScriptDirectory(withReply reply: @escaping (String) -> Void) {
        NSWorkspace.shared.open(FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0])
        reply("SzContext XPC service: Script folder opened")
    }
    
    func loadBookmark(withReply reply: @escaping (String) -> Void) {
         _ = BookmarkManager.loadHelperBookmarks()
        reply("SzContext XPC service: Helper bookmarks loaded")
    }
    
    func updateBookmarks(minimalBookmark: Data, withReply reply: @escaping (String) -> Void) {
        if BookmarkManager.saveSecurityBookmark(minimalBookmark: minimalBookmark) {
            reply("SzContext XPC service: Bookmark successfully updated")
        } else {
            reply("SzContext XPC service: Bookmark fails to be updated")
        }
    }
    
    func openFiles(urlFiles: [URL], urlApp: URL, withReply reply: @escaping (String) -> Void){
        do {
            if let urlFile = urlFiles.first {
                if urlFile.hasDirectoryPath {
                    _ = try FileManager.default.contentsOfDirectory(atPath: urlFiles[0].path)
                } else {
                    _ = try FileManager.default.contentsOfDirectory(atPath: urlFiles[0].deletingLastPathComponent().path)
                }
            }
        } catch  {
            reply("SzContext XPC service: Error open files")
        }
        
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
        if urlFiles.count == 1 && !urlFiles[0].hasDirectoryPath {
            if isTerminal(appBundleID: Bundle(path: urlApp.path)?.bundleIdentifier) {
                NSWorkspace.shared.open([urlFiles[0].deletingLastPathComponent()], withApplicationAt: urlApp, configuration: configOpen)
            } else {
                NSWorkspace.shared.open(urlFiles, withApplicationAt: urlApp, configuration: configOpen)
            }
        } else {
            NSWorkspace.shared.open(urlFiles, withApplicationAt: urlApp, configuration: configOpen)
        }
        reply("SzContext XPC service: Success open files")
    }
    
    func executeApplescript(name: String, withReply reply: @escaping (String) -> Void) {
        let url = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)[0].appendingPathComponent(name)
        let appleScript = try? NSUserAppleScriptTask.init(url: url)
        appleScript?.execute(completionHandler: nil)
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
