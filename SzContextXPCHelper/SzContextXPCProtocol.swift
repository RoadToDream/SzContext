//
//  SzContextXPCProtocol.h
//  SzContextXPC
//
//  Created by Jiawei Duan on 12/27/20.
//  Copyright © 2020 Jiawei Duan. All rights reserved.
//
import Foundation

@objc public protocol SzContextXPCProtocol {
    func checkVersion(withReply reply: @escaping (String) -> Void)
    func loadBookmark(withReply reply: @escaping (String) -> Void)
    func updateBookmarks(minimalBookmark: Data, withReply reply: @escaping (String) -> Void)
    func openFiles(urlFiles: [URL], urlApp: URL, withReply reply: @escaping (String) -> Void)
}
