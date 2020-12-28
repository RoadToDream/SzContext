//
//  SzContextXPCDelegate.swift
//  SzContextXPC
//
//  Created by Jiawei Duan on 12/27/20.
//  Copyright © 2020 Jiawei Duan. All rights reserved.
//

import Foundation

class SzContextXPCDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let exportedObject = SzContextXPC()
        newConnection.exportedInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}
