//
//  main.m
//  SzContextXPC
//
//  Created by Jiawei Duan on 12/27/20.
//  Copyright © 2020 Jiawei Duan. All rights reserved.
//

import Foundation

let delegate = SzContextXPCDelegate()
let listener = NSXPCListener(machServiceName: MACH_SERVICE)
listener.delegate = delegate
listener.resume()

PreferenceManager.set(for: .xpcVersion, with: XPC_VERSION)
BookmarkManager.loadHelperBookmarks()

RunLoop.current.run()


