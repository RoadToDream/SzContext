//
//  XPCService.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/6/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation
import LQ3C7Y6F8J_com_roadtodream_SzContextXPCHelper
import OSLog

class XPCServiceManager {
    static func versionXPC() -> String {
        let dispatch = Dispatch.DispatchSemaphore.init(value: 0)
        let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()
        var version = ""
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            dispatch.signal()
            os_log("SzContext: Received error from XPC %@ ", error.localizedDescription)
        } as? SzContextXPCProtocol
        service?.checkVersion(){ response in
            version = response
            dispatch.signal()
            os_log("SzContext: XPC service version %@ ",response)
        }
        dispatch.wait()
        return version
    }
    
    static func openXPCScriptDirectory() {
        let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            os_log("SzContext: Received error from XPC %@", error.localizedDescription)
        } as? SzContextXPCProtocol
        service?.openScriptDirectory(){ response in
            os_log("%@", response)
        }
    }
    
    static func loadXPCBookmark() {
        let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            os_log("SzContext: Received error from XPC %@", error.localizedDescription)
        } as? SzContextXPCProtocol
        service?.loadBookmark(){ response in
            os_log("%@", response)
        }
    }
    
    static func bookmarkXPCUpdate(minimalBookmark: Data) -> Bool {
        let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
        connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        connection.resume()
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            os_log("SzContext: Received error from XPC %@", error.localizedDescription)
        } as? SzContextXPCProtocol
        if versionXPC() != XPC_VERSION {
            return false
        }
        service?.updateBookmarks(minimalBookmark: minimalBookmark){ response in
            os_log("%@", response)
        }
        return true
    }

}
