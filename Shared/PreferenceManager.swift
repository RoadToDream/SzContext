//
//  PreferenceManager.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/3/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation

class PreferenceManager {
    public static let manager = PreferenceManager()
    static private let ud = UserDefaults.init(suiteName: APP_GROUP)
    
    class SharedBookmark:Codable {
        var mainBookmark: Data?
        var helperBookmark: Data?
        init(_ main: Data? = nil, _ helper: Data? = nil) {
            self.mainBookmark = main
            self.helperBookmark = helper
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
        static let bookmarkAccessFolder = Key("bookmark.Access.Folder")
        static let bookmarkScriptFolder = Key("bookmark.Script.Script.Folder")
//        static let appOpenAction = Key("app.Open.Action")
    }
    
    static let defaultPreference: [PreferenceManager.Key: [URL:PreferenceManager.SharedBookmark]] = [
        .bookmarkAccessFolder: [URL:PreferenceManager.SharedBookmark](),
        .bookmarkScriptFolder: [URL:PreferenceManager.SharedBookmark](),
//        .appOpenAction: [URL:[Any?]]()
    ]
    
    static func set(for key: Key, with data: [URL:PreferenceManager.SharedBookmark]) {
        ud?.setValue(try? PropertyListEncoder().encode(data), forKey: key.rawValue)
    }
    
    static func get(for key: Key) -> [URL:PreferenceManager.SharedBookmark] {
        let data = ud?.object(forKey: key.rawValue)
        if let dataDecoded = try? PropertyListDecoder().decode([URL:PreferenceManager.SharedBookmark].self, from: data as! Data){
            return dataDecoded
        }
        return [URL:PreferenceManager.SharedBookmark]()
    }
    
    static func reset() {
        for preference in defaultPreference {
            self.set(for: preference.key, with: preference.value)
        }
    }
}
