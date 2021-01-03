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
        let exportedInterface = NSXPCInterface(with: SzContextXPCProtocol.self)
        let inputSet = NSSet(objects: NSArray.self, NSString.self,NSURL.self,NSData.self) as! Set<AnyHashable>
        exportedInterface.setClasses(inputSet, for: #selector(SzContextXPCProtocol.updateBookmarks(_:withReply:)), argumentIndex: 0, ofReply: false)
        exportedInterface.setClasses(inputSet, for: #selector(SzContextXPCProtocol.openFiles(_:_:withReply:)), argumentIndex: 0, ofReply: false)


        newConnection.exportedInterface = exportedInterface
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}
