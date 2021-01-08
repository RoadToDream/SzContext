//
//  BookmarkManager.swift
//  LoginItemXPC
//
//  Created by Jiawei Duan on 12/30/20.
//

import Foundation
import Cocoa

class BookmarkManager {
    
    enum source {
        case access
        case script
    }
    
    static func allowFolder(for url: URL?, with option: PreferenceManager.Key, note str: String) -> URL? {
        
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.directoryURL = url
        openPanel.message = str
        
        if let mainWindow = NSApplication.shared.mainWindow {
            openPanel.beginSheetModal(for: mainWindow){(response) in
                if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                    self.saveBookmark(for: [openPanel.url!], with: option)
                }
                NSApplication.shared.stopModal(withCode: .OK)
            }
            NSApplication.shared.runModal(for: mainWindow)
        } else {
            let result = openPanel.runModal()
            if result == .OK {
                self.saveBookmark(for: [openPanel.url!], with: option)
            }
        }
        return openPanel.url
    }
    
    static func allowFolder(for url: URL?, with option: PreferenceManager.Key, note str: String, window: NSWindow?) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.directoryURL = url
        openPanel.message = str
        
        openPanel.beginSheetModal(for: window!){(response) in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                self.saveBookmark(for: [openPanel.url!], with: option)
            }
            NSApplication.shared.stopModal(withCode: .OK)
        }
        NSApplication.shared.runModal(for: window!)
        return openPanel.url
    }
    
    static func isBookmarkEmpty(with option: PreferenceManager.Key) -> Bool {
        if (PreferenceManager.bookmark(for: option)).isEmpty {
            return true
        } else {
            return false
        }
    }
    
    static func saveBookmark(for urls: [URL], with option: PreferenceManager.Key) {
        var existingBookmarkDict = PreferenceManager.bookmark(for: option)
        
        for url in urls {
            if let data = try? url.bookmarkData(options: NSURL.BookmarkCreationOptions.minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil) {
                existingBookmarkDict[url]=PreferenceManager.SharedBookmark(data)
            }
        }
        PreferenceManager.set(for: option, with: existingBookmarkDict)
    }
    
    static func saveBookmarkFromMinimal(with option: PreferenceManager.Key) {
        var existingBookmarkDict = PreferenceManager.bookmark(for: option)
        var stale = false
        for bookmark in existingBookmarkDict {
            if let mainBookmark = bookmark.value.mainBookmark {
                let restoredUrl = try! URL.init(resolvingBookmarkData: mainBookmark, options: NSURL.BookmarkResolutionOptions.withoutUI, relativeTo: nil, bookmarkDataIsStale: &stale)
                let helperBookmark = try! restoredUrl.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                existingBookmarkDict[bookmark.key] = PreferenceManager.SharedBookmark(mainBookmark,helperBookmark)
            }
            
        }
        PreferenceManager.set(for: option, with: existingBookmarkDict)
    }
    
    static func loadMainBookmarks(with option: PreferenceManager.Key) {
        let existingBookmarkDict = PreferenceManager.bookmark(for: option)
        
        for bookmark in existingBookmarkDict {
            if let data = try? bookmark.key.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil){
                restoreBookmark(data: data)
            }
        }
    }
    
    static func loadHelperBookmarks(with option: PreferenceManager.Key) -> Bool {
        let existingBookmarkDict = PreferenceManager.bookmark(for: option)
        if !existingBookmarkDict.isEmpty {
            for bookmark in existingBookmarkDict {
                if let helperBookmark = bookmark.value.helperBookmark {
                    restoreBookmark(data: helperBookmark)
                }
            }
            return true
        } else {
            return false
        }
        
    }
    
    static func stopAccessing(with option: PreferenceManager.Key){
        let existingBookmarkDict = PreferenceManager.bookmark(for: option)

        for bookmark in existingBookmarkDict {
            if let helperBookmark = bookmark.value.helperBookmark {
                stopAccessingBookmark(data: helperBookmark)
            }
        }
    }
    
    static private func restoreBookmark(data: Data){
        var restoredUrl: URL?
        var isStale = false
        do{
            restoredUrl = try URL.init(resolvingBookmarkData: data, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        }
        catch{
            restoredUrl = nil
        }
        if let url = restoredUrl{
            if !isStale{
                print(url.startAccessingSecurityScopedResource())
            }
        }
    }
    
    static private func stopAccessingBookmark(data: Data){
        var restoredUrl: URL?
        var isStale = false
        do{
            restoredUrl = try URL.init(resolvingBookmarkData: data, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        }
        catch{
            restoredUrl = nil
        }
        if let url = restoredUrl{
            if !isStale{
                url.stopAccessingSecurityScopedResource()
            }
        }
    }
}
 
