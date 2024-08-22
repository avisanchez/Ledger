//
//  TableCommands.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/18/24.
//

import Foundation
import SwiftUI

struct TableCommands: Commands {

    @Environment(ViewController.self) var viewController
    
    var body: some Commands {
        CommandMenu("Table") {
            Button("Add Row Above") {
                guard let selectedAccount = viewController.selectedAccount else { return }
                let selectedEntry =  viewController.selectedEntry
                let newEntry = CDController.createEntry(for: selectedAccount, above: selectedEntry)
                CDController.updateRunningTotals(from: newEntry,
                                                 to: newEntry,
                                                 useRoundedTotals: viewController.useRoundedTotals)
            }
            
            Button("Add Row Below") {
                guard let selectedAccount = viewController.selectedAccount else { return }
                let selectedEntry = viewController.selectedEntry
                let newEntry = CDController.createEntry(for: selectedAccount, below: selectedEntry)
                CDController.updateRunningTotals(from: newEntry,
                                                 to: newEntry,
                                                 useRoundedTotals: viewController.useRoundedTotals)
            }
            
            Divider()
            
            Button("Delete Row") {
                guard let selectedEntry = viewController.selectedEntry else { return }
                let useRoundedTotals = viewController.useRoundedTotals
                
                PersistenceController.shared.viewContext.perform {
                    CDController.delete(selectedEntry, useRoundedTotals: useRoundedTotals) { success, newValue in
                        guard success, let newValue else { return }
                        viewController.selectedEntry = newValue
                    }
                }
            }
            .keyboardShortcut(.deleteRow)
            
            Divider()
            
            Menu("Jump To") {
                Button("Top") {
                    
                }
                .keyboardShortcut(.jumpToTop)
                
                Button("Bottom") {
                }
                .keyboardShortcut(.jumpToBottom)
                
                Button("Selection") {
                }
                .keyboardShortcut(.jumpToSelection)
                
            }
            .disabled(true)

            
            Divider()
            
            Button("Zoom In") {
                guard viewController.tableScale != TableScale.allCases.last else { return }
                viewController.tableScale = viewController.tableScale.advanced(by: 1)
            }
            .keyboardShortcut(KeyEquivalent("+"), modifiers: .command)
            
            Button("Zoom Out") {
                guard viewController.tableScale != TableScale.allCases.first else { return }
                viewController.tableScale = viewController.tableScale.advanced(by: -1)
            }
            .keyboardShortcut(KeyEquivalent("-"), modifiers: .command)
            
        }
    }
}
