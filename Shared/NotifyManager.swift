//
//  NotifyManager.swift
//  SzContext
//
//  Created by Jiawei Duan on 1/6/21.
//  Copyright © 2021 Jiawei Duan. All rights reserved.
//

import Foundation
import Cocoa

class NotifyManager {
    static func messageNotify(message: String, inform: String, style: NSAlert.Style ) -> Bool {
        let messageWindow = NSAlert()
        messageWindow.messageText = message
        messageWindow.informativeText = inform
        messageWindow.alertStyle = style
        if style == .informational {
            messageWindow.addButton(withTitle: NSLocalizedString("general.OK", comment: ""))
        } else {
            messageWindow.addButton(withTitle: NSLocalizedString("general.Confirm", comment: ""))
            messageWindow.addButton(withTitle: NSLocalizedString("general.Cancel", comment: ""))
        }
        return messageWindow.runModal() == .alertFirstButtonReturn
    }
}
