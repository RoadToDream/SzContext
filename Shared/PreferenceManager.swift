//
//  PreferenceManager.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/3/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa

class PreferenceManager {
    static private var ud = UserDefaults.init(suiteName: APP_GROUP)
    
    class SharedBookmark:Codable {
        var helperBookmark: Data?
        init(_ helper: Data? = nil) {
            self.helperBookmark = helper
        }
    }
    
    class AppWithOptions: NSObject, Codable, NSPasteboardWriting, NSPasteboardReading {
        func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
            return [NSPasteboard.PasteboardType.init("com.roadtodream.szcontext.appwithoptions")]
        }
        
        func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
            return try? PropertyListEncoder().encode(self)
        }
        
        static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
            return [NSPasteboard.PasteboardType.init("com.roadtodream.szcontext.appwithoptions")]
        }
        
        required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
            if let data = propertyList as? Data {
                if let decodedData = try? PropertyListDecoder().decode(AppWithOptions.self, from: data)  {
                    app = decodedData.app
                    options = decodedData.options
                } else {
                    return nil
                }
            } else {
                return nil 
            }
            
        }
        
        var app : URL
        var options : [String]
        init(_ app: URL, _ options: [String]) {
            self.app = app
            self.options = options
        }
    }
    
    struct Key: RawRepresentable, Hashable {
        typealias RawValue = String

        var rawValue: RawValue

        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }

        init(_ string: String) { self.rawValue = string }

        init?(rawValue: RawValue) { self.rawValue = rawValue }
        static let userDefaultsVersion = Key("user.Defaults.Version")
        static let xpcVersion = Key("xpc.Version")
        static let notFirstLaunch = Key("not.First.Launch")
        static let urlAccessFolder = Key("url.Access.Folder")
        static let bookmarkAccessFolder = Key("bookmark.Access.Folder")
        static let appWithOption = Key("app.With.Option")
        static let showIconsOption = Key("show.Icons.Option")
        static let accessExternalVolume = Key("access.External.Volume")
        static let showOpenRecent = Key("show.Open.Recent")
    }
    
    static let defaultPreference: [PreferenceManager.Key: Any?] = [
        .userDefaultsVersion: USER_DEFAULTS_VERSION,
        .xpcVersion: XPC_VERSION,
        .notFirstLaunch: false,
        .urlAccessFolder: [URL](),
        .bookmarkAccessFolder: [URL:PreferenceManager.SharedBookmark](),
        .appWithOption: [AppWithOptions(NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal")!,[String()])],
        .showIconsOption: true,
        .accessExternalVolume: false,
        .showOpenRecent: false
    ]
    
    static func set(for key: Key, with data: Double) {
        ud?.removeObject(forKey: key.rawValue)
        ud?.setValue(data, forKey: key.rawValue)
    }
    
    static func set(for key: Key, with data: Bool) {
        ud?.removeObject(forKey: key.rawValue)
        ud?.setValue(data, forKey: key.rawValue)
    }
    
    static func set(for key: Key, with data: String) {
        ud?.removeObject(forKey: key.rawValue)
        ud?.setValue(data, forKey: key.rawValue)
    }
    
    static func set(for key: Key, with data: [URL]) {
        ud?.removeObject(forKey: key.rawValue)
        ud?.setValue(try? PropertyListEncoder().encode(data), forKey: key.rawValue)
        DistributedNotificationCenter.default().post(name: Notification.Name("onUpdateMonitorFolder"), object: nil)
    }
    
    static func set(for key: Key, with data: [AppWithOptions], updateIcon: Bool) {
        ud?.removeObject(forKey: key.rawValue)
        if updateIcon {
            let iconManager = IconCacheManager.init(name:"SzContext")
            for app in data {
                iconManager.addPersistentIcon(appURL: app.app)
            }
        }
        ud?.setValue(try? PropertyListEncoder().encode(data), forKey: key.rawValue)
    }
    
    static func set(for key: Key, with data: [URL:PreferenceManager.SharedBookmark]) {
        ud?.removeObject(forKey: key.rawValue)
        ud?.setValue(try? PropertyListEncoder().encode(data), forKey: key.rawValue)
        self.set(for: .urlAccessFolder, with: Array(data.keys))
        XPCServiceManager.loadXPCBookmark()
    }
    
    static func bool(for key: Key) -> Bool {
        if let user = ud {
            return user.bool(forKey: key.rawValue)
        }
        return false
    }
    
    static func userDefaultsVersion() -> String {
        if let user = ud,
           let str = user.string(forKey: Key.userDefaultsVersion.rawValue) {
            return str
        }
        return ""
    }
    
    static func xpcVersion() -> String {
        if let user = ud,
           let str = user.string(forKey: Key.xpcVersion.rawValue) {
            return str
        }
        return ""
    }
    
    static func urlAccess() -> [URL] {
        if let data = ud?.object(forKey: Key.urlAccessFolder.rawValue) as? Data {
            if let dataDecoded = try? PropertyListDecoder().decode([URL].self, from: data){
                return dataDecoded
            }
        }
        return []
    }
    
    static func appWithOption() -> [AppWithOptions] {
        if let data = ud?.object(forKey: Key.appWithOption.rawValue) as? Data {
            if let dataDecoded = try? PropertyListDecoder().decode([AppWithOptions].self, from: data){
                return dataDecoded
            }
        }
        return [AppWithOptions]()
    }
    
    static func bookmark() -> [URL:PreferenceManager.SharedBookmark] {
        if let data = ud?.object(forKey: Key.bookmarkAccessFolder.rawValue) as? Data{
            if let dataDecoded = try? PropertyListDecoder().decode([URL:PreferenceManager.SharedBookmark].self, from: data){
                return dataDecoded
            }
        }
        return [URL:PreferenceManager.SharedBookmark]()
    }
    
    static func versionUpdate() -> Bool {
        let from = self.userDefaultsVersion(), to = USER_DEFAULTS_VERSION
        if (from == "1" || from == "1.0") && to == "1.1" {
            if let data = ud?.object(forKey: Key.bookmarkAccessFolder.rawValue) as? Data,
               let bookmarks = try? PropertyListDecoder().decode([URL:PreferenceManager.SharedBookmark].self, from: data) {
                var updatedBookmark = [URL:PreferenceManager.SharedBookmark]()
                for bookmark in bookmarks {
                    updatedBookmark[bookmark.key] = SharedBookmark(bookmark.value.helperBookmark)
                }
                self.set(for: .bookmarkAccessFolder, with: updatedBookmark)
                ud?.removeObject(forKey: "rul.Access.Folder")
                return true
            }
        }
        return false
    }
    
    static func resetApp() {
        self.set(for: .appWithOption, with: self.defaultPreference[.appWithOption] as! [AppWithOptions], updateIcon: true)
    }
    
    static func resetAccessFolder() {
        self.set(for: .bookmarkAccessFolder, with: self.defaultPreference[.bookmarkAccessFolder] as! [URL:PreferenceManager.SharedBookmark])
    }
    
    static func resetUserDefaultsVersion() {
        self.set(for: .userDefaultsVersion, with: self.defaultPreference[.userDefaultsVersion] as! String)
    }
    
    static func reset() {
        self.set(for: .userDefaultsVersion, with: self.defaultPreference[.userDefaultsVersion] as! String)
        self.set(for: .urlAccessFolder, with: self.defaultPreference[.urlAccessFolder] as! [URL])
        self.set(for: .bookmarkAccessFolder, with: self.defaultPreference[.bookmarkAccessFolder] as! [URL:PreferenceManager.SharedBookmark])
        self.set(for: .appWithOption, with: self.defaultPreference[.appWithOption] as! [AppWithOptions], updateIcon: true)
        self.set(for: .showIconsOption, with: self.defaultPreference[.showIconsOption] as! Bool)
        self.set(for: .accessExternalVolume, with: self.defaultPreference[.accessExternalVolume] as! Bool)
        self.set(for: .showOpenRecent, with: self.defaultPreference[.showOpenRecent] as! Bool)
        ud?.synchronize()
    }
}
