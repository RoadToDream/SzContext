//
//  BookmarkManager.swift
//  LoginItemXPC
//
//  Created by Jiawei Duan on 12/30/20.
//

import Foundation
import Cocoa

public class BookmarkManager {
    public static let manager = BookmarkManager()
    
    public func allowFolder(url: URL?) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.directoryURL = url
        let result = openPanel.runModal()
        if result == NSApplication.ModalResponse.OK {
            self.saveBookmark(for: [openPanel.url!])
        }
        return openPanel.url
    }
    
    public func isBookmarkEmpty() -> Bool {
        guard let bookmarkDatabaseURL = self.getBookmarkDatabaseURL() else {
            return true
        }

        if self.fileExists(bookmarkDatabaseURL) {
            do {
                let fileData = try Data(contentsOf: bookmarkDatabaseURL)
                if let fileBookmarks = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! [URL:Data]?{
                    return fileBookmarks.isEmpty
                }
            }
            catch {
                debugPrint("Couldn't load bookmarks")
            }
        }
        return true
    }
    
    public func saveBookmark(for urls: [URL]){
        var bookmarkDic = self.getBookmarksData(urls: urls)
        guard let bookmarkDatabaseURL = self.getBookmarkDatabaseURL() else{
                debugPrint("Error getting data or bookmarkURL")
                return
        }
        do{
            if fileExists(bookmarkDatabaseURL) {
                if let existingBookmarkDict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(try! Data(contentsOf: bookmarkDatabaseURL)) as! [URL:Data]?{
                    bookmarkDic.merge(existingBookmarkDict, uniquingKeysWith: {(_, new) in new})
                }
            }
            let dataArchive = try NSKeyedArchiver.archivedData(withRootObject: bookmarkDic, requiringSecureCoding: false)
            try dataArchive.write(to: bookmarkDatabaseURL)
            debugPrint("Did save data to url")
        }
        catch{
            debugPrint("Couldn't save bookmarks")
        }
    }
    
    public func loadBookmarks(){
        guard let url = self.getBookmarkDatabaseURL() else {
            return
        }
        if self.fileExists(url){
            do{
                let fileData = try Data(contentsOf: url)
                if let fileBookmarks = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! [URL:Data]?{
                    self.restoreBookmark(datas:fileBookmarks)
                }
            }
            catch{
                debugPrint("Couldn't load bookmarks")
            }
        }
        return
    }
    
    public func stopAccessing(){
        guard let url = self.getBookmarkDatabaseURL() else {
            return
        }
        if self.fileExists(url){
            do{
                let fileData = try Data(contentsOf: url)
                if let fileBookmarks = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! [URL:Data]?{
                    self.stopAccessingBookmark(datas: fileBookmarks)
                }
            }
            catch{
                debugPrint("Couldn't load bookmarks")
            }
        }
        return
    }
    
    public func getMinimalBookmark() -> [Data]{
        guard let url = self.getBookmarkDatabaseURL() else {
            return []
        }
        var newMinimalData = [Data]()
        if self.fileExists(url){
            do{
                let fileData = try Data(contentsOf: url)
                if let fileBookmarks = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! [URL:Data]?{
                    for bookmark in fileBookmarks{
                        let restoredUrl: URL
                        var isStale = false
                        restoredUrl = try! URL.init(resolvingBookmarkData: bookmark.value, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                        _ = restoredUrl.startAccessingSecurityScopedResource()
                        newMinimalData.append(try! restoredUrl.bookmarkData(options: URL.BookmarkCreationOptions.minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil))
                    }
                    return newMinimalData
                }
            }
            catch{
                debugPrint("failed get minimal data")
            }
        }
        return []
    }
    
    private func restoreBookmark(datas: [URL:Data]){
        var restoredUrl: URL?
        var isStale = false
        for data in datas {
            do{
                restoredUrl = try URL.init(resolvingBookmarkData: data.value, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            }
            catch{
                debugPrint("Error restoring bookmarks")
                restoredUrl = nil
            }
            if let url = restoredUrl{
                if isStale{
                    debugPrint("URL is stale")
                }
                else{
                    if !url.startAccessingSecurityScopedResource(){
                        debugPrint("Couldn't access: \(url.path)")
                    }
                }
            }
        }
    }
    
    private func stopAccessingBookmark(datas: [URL:Data]){
        var restoredUrl: URL?
        var isStale = false
        for data in datas {
            do{
                restoredUrl = try URL.init(resolvingBookmarkData: data.value, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            }
            catch{
                debugPrint("Error restoring bookmarks")
                restoredUrl = nil
            }
            if let url = restoredUrl{
                if isStale{
                    debugPrint("URL is stale")
                }
                else{
                    url.stopAccessingSecurityScopedResource()
                }
            }
        }
    }
    
    private func getBookmarksData(urls: [URL]) -> [URL: Data]{
        var bookmarkData = [URL: Data]()
        for url in urls {
            if let data = try? url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil){
                bookmarkData[url]=data
            }
        }
        return bookmarkData
    }

    public func getBookmarkDatabaseURL() -> URL? {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        if let appSupportURL = urls.last{
            let url = appSupportURL.appendingPathComponent("Bookmarks.db")
            return url
        }
        return nil
    }

    private func fileExists(_ url: URL) -> Bool{
        return FileManager.default.fileExists(atPath: url.path, isDirectory: nil)
    }

}
