//
//  Util.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/14/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation

extension String {
    func isChildPath(of urls: [URL]) -> Bool {
        for url in urls {
            if self.count >= url.path.count {
                let monitorComponents = URL(fileURLWithPath: url.path).pathComponents
                if monitorComponents == Array(URL(fileURLWithPath: self).pathComponents.prefix(monitorComponents.count)) {
                    return true
                }
            }
        }
        return false
    }
}
