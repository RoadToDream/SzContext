//
//  SzContextServiceProtocal.swift
//  SzContextService
//
//  Created by Jiawei Duan on 2018/8/26.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa


class SzContextServiceProtocol: NSObject {
    @objc func openURL(_ pasteboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>)
    {
        let urls=pasteboard.string(forType: .string)!.components(separatedBy: "\n").map { URL(fileURLWithPath: $0) }
        do
        {
            try NSWorkspace.shared.open(Array(urls[1..<urls.count]), withApplicationAt: urls[0] ,options: .default, configuration: [:])
        }
        catch
        {
            return
        }
    }
}
