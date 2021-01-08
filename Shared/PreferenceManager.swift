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
        var mainBookmark: Data?
        var helperBookmark: Data?
        init(_ main: Data? = nil, _ helper: Data? = nil) {
            self.mainBookmark = main
            self.helperBookmark = helper
        }
    }
    
    class AppWithOptions: Codable {
        var _app : URL
        var _options : [String]
        init(_ app: URL, _ options: [String]) {
            self._app = app
            self._options = options
        }
        func app() -> URL {
            return self._app
        }
        func options() -> [String] {
            return self._options
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
        static let notFirstLaunch = Key("not.First.Launch")
        static let bookmarkAccessFolder = Key("bookmark.Access.Folder")
        static let bookmarkScriptFolder = Key("bookmark.Script.Script.Folder")
        static let appWithOption = Key("app.With.Option")
        static let enalbeScriptFolder = Key("enable.Script.Folder")
    }
    
    static let defaultPreference: [PreferenceManager.Key: Any?] = [
        .notFirstLaunch: false,
        .bookmarkAccessFolder: [URL:PreferenceManager.SharedBookmark](),
        .bookmarkScriptFolder: [URL:PreferenceManager.SharedBookmark](),
        .appWithOption: [AppWithOptions(NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal")!,[String()])],
        .enalbeScriptFolder: false
    ]
    
    
    static func set(for key: Key, with data: Bool) {
        ud?.removeObject(forKey: key.rawValue)
        ud?.setValue(data, forKey: key.rawValue)
    }
    
    static func set(for key: Key, with data: [AppWithOptions]) {
        ud?.removeObject(forKey: key.rawValue)
        ud?.setValue(try? PropertyListEncoder().encode(data), forKey: key.rawValue)
    }
    
    static func set(for key: Key, with data: [URL:PreferenceManager.SharedBookmark]) {
        ud?.removeObject(forKey: key.rawValue)
        ud?.setValue(try? PropertyListEncoder().encode(data), forKey: key.rawValue)
    }
    
    static func bool(for key: Key) -> Bool {
        if let user = ud {
            return user.bool(forKey: key.rawValue)
        }
        return false
    }
    
    static func appWithOption(for key: Key) -> [AppWithOptions] {
        if let data = ud?.object(forKey: key.rawValue) {
            if let dataDecoded = try? PropertyListDecoder().decode([AppWithOptions].self, from: data as! Data){
                return dataDecoded
            }
        }
        return [AppWithOptions]()
    }
    
    static func bookmark(for key: Key) -> [URL:PreferenceManager.SharedBookmark] {
        if let data = ud?.object(forKey: key.rawValue) {
            if let dataDecoded = try? PropertyListDecoder().decode([URL:PreferenceManager.SharedBookmark].self, from: data as! Data){
                return dataDecoded
            }
        }
        return [URL:PreferenceManager.SharedBookmark]()
    }
    
    static func resetApp() {
        self.set(for: .appWithOption, with: self.defaultPreference[.appWithOption] as! [AppWithOptions])
    }
    
    static func reset() {
        self.set(for: .bookmarkAccessFolder, with: self.defaultPreference[.bookmarkAccessFolder] as! [URL:PreferenceManager.SharedBookmark])
        self.set(for: .bookmarkScriptFolder, with: self.defaultPreference[.bookmarkScriptFolder] as! [URL:PreferenceManager.SharedBookmark])
        self.set(for: .appWithOption, with: self.defaultPreference[.appWithOption] as! [AppWithOptions])
        self.set(for: .enalbeScriptFolder, with: self.defaultPreference[.enalbeScriptFolder] as! Bool)
        ud?.synchronize()
    }
}
