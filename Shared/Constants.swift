//
//  Constants.swift
//  LoginItemXPCHelper
//
//  Created by Jiawei Duan on 12/29/20.
//

import Foundation

let MACH_SERVICE = "LQ3C7Y6F8J.com.roadtodream.SzContextXPCHelper"
let HELPER_BUNDLE = "LQ3C7Y6F8J.com.roadtodream.SzContextXPCHelper"
let MAIN_BUNDLE = "com.roadtodream.SzContext"
let APP_GROUP = "LQ3C7Y6F8J.com.roadtodream"
let URL_SCHEME_NAME = "szcontext"

let XPC_VERSION = "1.2"
let USER_DEFAULTS_VERSION = "1.1"

enum terminalID : String, CaseIterable {
    case terminal = "com.apple.Terminal"
    case iTerm = "com.googlecode.iterm2"
    case hyper = "co.zeit.hyper"
    case alacritty = "io.alacritty"
    case kitty = "net.kovidgoyal.kitty"
}

enum editorID : String, CaseIterable {
    case textEdit = "com.apple.TextEdit"
    case vscode = "com.microsoft.VSCode"
    case atom = "com.github.atom"
    case sublime = "com.sublimetext.3"
    case vscodium = "com.visualstudio.code.oss"
    case bbedit = "com.barebones.bbedit"
    case vscodeInsiders = "com.microsoft.VSCodeInsiders"
    case textMate = "com.macromates.TextMate"
    
    // JetBrains
    case appCode = "com.jetbrains.appcode"
    case cLion = "com.jetbrains.clion"
    case goLand = "com.jetbrains.goland"
    case intelliJIDEA = "com.jetbrains.intellij"
    case phpStorm = "com.jetbrains.PhpStorm"
    case pyCharm = "com.jetbrains.pycharm"
    case rubyMine = "com.jetbrains.rubymine"
    case webStorm = "com.jetbrains.webstorm"
}
