//
//  IconCachePersistentContainer.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/9/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation
import CoreData
import Cocoa
import OSLog

class IconCacheManager: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        if let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: APP_GROUP) {
            return storeURL.appendingPathComponent("Library").appendingPathComponent("Caches").appendingPathComponent("SzContextIconCache.sqlite")
        }
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathExtension("SzContextIconCache.sqlite")
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let iconCacheContainer = IconCacheManager(name: "SzContext")
        let description = iconCacheContainer.persistentStoreDescriptions.first
        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        description?.setOption(true as NSNumber, forKey: remoteChangeKey)
        
        iconCacheContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return iconCacheContainer
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func addPersistentIcon(appURL: URL) {
        let context = persistentContainer.viewContext
        let iconCache = IconCache(context: context)
        let iconSet = NSWorkspace.shared.icon(forFile: appURL.path)
        let iconSingle = NSImage()
        for iconRep in iconSet.representations {
            if iconRep.size == NSSize(width: 32, height: 32) {
                iconSingle.addRepresentation(iconRep)
            }
        }
        iconCache.path = appURL.path
        iconCache.icon = iconSingle.tiffRepresentation
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        do {
            try context.save()
        } catch {
            os_log("SzContext: Error saving icon cache")
        }
    }
    
    func fetchPersistentIcon() -> [String:NSImage] {
        var result = [String:NSImage]()
        let context = persistentContainer.viewContext
        let iconFetchRequest = NSFetchRequest<IconCache>(entityName: "IconCache")
        do {
            let iconsCache = try context.fetch(iconFetchRequest)
            for iconCache in iconsCache {
                result[iconCache.path!] = NSImage(data: iconCache.icon!)
            }
            return result
        }
        catch {
            return result
        }
    }
    
}
