//
//  SzContextXPC.m
//  SzContextXPC
//
//  Created by Jiawei Duan on 12/27/20.
//  Copyright © 2020 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa


class SzContextXPC: NSObject, SzContextXPCProtocol {
    func openFiles(_ urlStr: String, withReply reply: @escaping (String) -> Void) {
        let response = "string.uppercased()"
        let urls=urlStr.components(separatedBy: "\n").map { URL(fileURLWithPath: $0) }
        do
        {
            try NSWorkspace.shared.open(Array(urls[1..<urls.count]), withApplicationAt: urls[0] ,options: .default, configuration: [:])
        }
        catch
        {
            reply(response)
            return
        }
        reply(response)
    }
}
