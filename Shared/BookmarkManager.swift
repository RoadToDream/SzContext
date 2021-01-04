//
//  BookmarkManager.swift
//  LoginItemXPC
//
//  Created by Jiawei Duan on 12/30/20.
//

import Foundation
import Cocoa

class BookmarkManager {
    public static let manager = BookmarkManager()
    
    enum source {
        case access
        case script
    }
    
    public func allowFolder(for url: URL?, with option: PreferenceManager.Key) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.directoryURL = url
        let result = openPanel.runModal()
        if result == NSApplication.ModalResponse.OK {
            self.saveBookmark(for: [openPanel.url!], with: option)
        }
        return openPanel.url
    }
    
    public func isBookmarkEmpty(with option: PreferenceManager.Key) -> Bool {
        if (PreferenceManager.get(for: option)).isEmpty {
            return true
        } else {
            return false
        }
    }
    
    public func saveBookmark(for urls: [URL], with option: PreferenceManager.Key) {
        var existingBookmarkDict = PreferenceManager.get(for: option)
        
        for url in urls {
            if let data = try? url.bookmarkData(options: NSURL.BookmarkCreationOptions.minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil) {
                existingBookmarkDict[url]=PreferenceManager.SharedBookmark(data)
            }
        }

        PreferenceManager.set(for: option, with: existingBookmarkDict)
    }
    
    public func saveBookmarkFromMinimal(with option: PreferenceManager.Key) {
        var existingBookmarkDict = PreferenceManager.get(for: option)
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
    
    public func loadMainBookmarks(with option: PreferenceManager.Key) {
        let existingBookmarkDict = PreferenceManager.get(for: option)
        
        for bookmark in existingBookmarkDict {
            let data = try! bookmark.key.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            restoreBookmark(data: data)
        }
    }
    
    public func loadHelperBookmarks(with option: PreferenceManager.Key) {
        let existingBookmarkDict = PreferenceManager.get(for: option)
        
        for bookmark in existingBookmarkDict {
            if let helperBookmark = bookmark.value.helperBookmark {
                restoreBookmark(data: helperBookmark)
            }
        }
    }
    
    public func stopAccessing(with option: PreferenceManager.Key){
        let existingBookmarkDict = PreferenceManager.get(for: option)

        for bookmark in existingBookmarkDict {
            if let helperBookmark = bookmark.value.helperBookmark {
                stopAccessingBookmark(data: helperBookmark)
            }
        }
    }
    
    private func restoreBookmark(data: Data){
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
    
    private func stopAccessingBookmark(data: Data){
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
 
