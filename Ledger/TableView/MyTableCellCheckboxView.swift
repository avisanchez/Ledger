//
//  NSTableCellViewWithCheckbox.swift
//  Ledger
//
//  Created by Avi Sanchez on 7/18/24.
//

import Foundation
import SwiftUI

class MyTableCellCheckboxView: NSTableCellView {
    
    @IBOutlet weak var checkbox: NSButton!
    
    var linkedObject: CDAccountEntry?
        
    override func viewWillDraw() {
        guard let linkedObject else { return }
        checkbox.state = linkedObject.posted ? .on : .off
    }
    
    @IBAction func changedState(_ sender: NSButtonCell) {
        switch sender.state {
        case .on:
            linkedObject?.posted = true
            break
        case .off:
            linkedObject?.posted = false
            break
        default:
            print("failed to change state")
            break
        }
        do {
            try PersistenceController.managedObjectContext.save()
        } catch {
            fatalError()
        }
        
    }
}
