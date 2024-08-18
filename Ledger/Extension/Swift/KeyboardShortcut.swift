//
//  KeyboardShortcut.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/16/24.
//

import Foundation
import SwiftUI

extension KeyboardShortcut {
    
    /// deletes the selected account or selected entry depending which view is focused
    static let deleteRow = KeyboardShortcut(.delete)
    
    /// toggles the useRoundedTotals preference
    static let roundTotals = KeyboardShortcut(KeyEquivalent("r"), modifiers: .command)
    
    /// creates a new account or entry depending on which view is focused
    static let create = KeyboardShortcut(KeyEquivalent("a"), modifiers: .command)
    
    static let undo = KeyboardShortcut(KeyEquivalent("z"), modifiers: .command)
    static let redo = KeyboardShortcut(KeyEquivalent("z"), modifiers: [.shift, .command])
    
    /// jumps to the top of the table view
    static let jumpToTop = KeyboardShortcut(.upArrow, modifiers: [.command, .option])
    
    /// jumps to the bottom of the table view
    static let jumpToBottom = KeyboardShortcut(.downArrow, modifiers: [.command, .option])
    
    /// jumps to the selected entry of the table view (does nothing if there is no selection)
    static let jumpToSelection = KeyboardShortcut(.space, modifiers: [.command, .shift])
}
