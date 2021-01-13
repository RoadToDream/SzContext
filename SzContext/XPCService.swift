//
//  XPCService.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/6/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation
import LQ3C7Y6F8J_com_roadtodream_SzContextXPCHelper

func versionXPC() -> String {
    let dispatch = Dispatch.DispatchSemaphore.init(value: 0)
    let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
    connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
    connection.resume()
    var version = ""
    let service = connection.remoteObjectProxyWithErrorHandler { error in
        dispatch.signal()
        debugPrint("Received error:", error)
    } as? SzContextXPCProtocol
    service?.checkVersion(){ response in
        version = response
        dispatch.signal()
        debugPrint(response)
    }
    dispatch.wait()
    return version
}

func bookmarkXPCUpdate() {
    let connection = NSXPCConnection(machServiceName: MACH_SERVICE, options: NSXPCConnection.Options(rawValue: 0))
    connection.remoteObjectInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
    connection.resume()
    let service = connection.remoteObjectProxyWithErrorHandler { error in
        debugPrint("Received error:", error)
    } as? SzContextXPCProtocol
    service?.updateBookmarks(){ response in
        debugPrint(response)
    }
}
