//
//  NSTextFieldDelegate.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/18/24.
//

import Foundation
import AppKit

class MyTableCellTextFieldView: NSTableCellView, NSTextFieldDelegate {
    var cachedObjectValue: Any?
    
    @IBAction func didCommit(_ sender: NSTextField) {
    }
    
    func controlTextDidBeginEditing(_ obj: Notification) {
        guard let sender = obj.object as? NSTextField else { return }
        cachedObjectValue = sender.objectValue
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let objectValue = control.objectValue
        print("objectValue: \(objectValue)")
        print("fieldEditor.string: \(fieldEditor.string)")
        if fieldEditor.string.isEmpty {
            control.objectValue = cachedObjectValue
        }
        return true
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let sender = obj.object as? NSTextField else { return }
    }
}
