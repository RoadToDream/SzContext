//
//  SzContextXPCProtocol.h
//  SzContextXPC
//
//  Created by Jiawei Duan on 12/27/20.
//  Copyright © 2020 Jiawei Duan. All rights reserved.
//
import Foundation

@objc public protocol SzContextXPCProtocol {
    func updateBookmarks(withReply reply: @escaping (String) -> Void)
    func openFiles(_ urlFiles: [URL], _ urlApp: URL, withReply reply: @escaping (String) -> Void)
}
