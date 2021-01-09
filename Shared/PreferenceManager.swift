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
        static let userDefaultsVersion = Key("user.Defaults.Version")
        static let notFirstLaunch = Key("not.First.Launch")
        static let urlAccessFolder = Key("rul.Access.Folder")
        static let bookmarkAccessFolder = Key("bookmark.Access.Folder")
        static let appWithOption = Key("app.With.Option")
        static let showIconsOption = Key("show.Icons.Option")
    }
    
    static let defaultPreference: [PreferenceManager.Key: Any?] = [
        .userDefaultsVersion: 1.0,
        .notFirstLaunch: false,
        .urlAccessFolder: [String](),
        .bookmarkAccessFolder: [URL:PreferenceManager.SharedBookmark](),
        .appWithOption: [AppWithOptions(NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal")!,[String()])],
        .showIconsOption: true
    ]
    
    static func set(for key: Key, with data: Double) {
        ud?.removeObject(forKey: key.rawValue)
        ud?.setValue(data, forKey: key.rawValue)
    }
    
    static func set(for key: Key, with data: Bool) {
        ud?.removeObject(forKey: key.rawValue)
        ud?.setValue(data, forKey: key.rawValue)
    }
    
    static func set(for key: Key, with data: [String]) {
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
        self.set(for: .urlAccessFolder, with: Array(data.keys).map{$0.path})
    }
    
    static func bool(for key: Key) -> Bool {
        if let user = ud {
            return user.bool(forKey: key.rawValue)
        }
        return false
    }
    
    static func url(for key: Key) -> [String] {
        if let user = ud {
            return user.object(forKey: key.rawValue) as? [String] ?? []
        }
        return []
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
        self.set(for: .userDefaultsVersion, with: self.defaultPreference[.userDefaultsVersion] as! Double)
        self.set(for: .urlAccessFolder, with: self.defaultPreference[.urlAccessFolder] as! [String])
        self.set(for: .bookmarkAccessFolder, with: self.defaultPreference[.bookmarkAccessFolder] as! [URL:PreferenceManager.SharedBookmark])
        self.set(for: .appWithOption, with: self.defaultPreference[.appWithOption] as! [AppWithOptions])
        self.set(for: .showIconsOption, with: self.defaultPreference[.showIconsOption] as! Bool)
        ud?.synchronize()
    }
}
