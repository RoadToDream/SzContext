//
//  SzContextService.swift
//  SzContextService
//
//  Created by Jiawei Duan on 2018/8/26.
//  Copyright © 2018 Jiawei Duan. All rights reserved.
//

import Foundation

import Cocoa

@objc(SzContextServiceApplication) class SzContextServiceApplication : NSApplication {
    override func finishLaunching() {
        super.finishLaunching()
        servicesProvider = SzContextServiceProtocol()
        NSUpdateDynamicServices()
    }
}
