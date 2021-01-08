//
//  XPCService.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/6/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation
import LQ3C7Y6F8J_com_roadtodream_SzContextXPCHelper

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
