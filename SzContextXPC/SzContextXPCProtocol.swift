//
//  SzContextXPCProtocol.h
//  SzContextXPC
//
//  Created by Jiawei Duan on 12/27/20.
//  Copyright © 2020 Jiawei Duan. All rights reserved.
//
import Foundation

@objc public protocol SzContextXPCProtocol {
    func openFiles(_ urlStr: String, withReply reply: @escaping (String) -> Void)
}
