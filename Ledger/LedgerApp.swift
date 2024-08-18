//
//  LedgerApp.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/8/24.
//

import SwiftUI
import SwiftData

@main
struct LedgerApp: App {
    @State private var viewController = ViewController(viewContext: PersistenceController.shared.viewContext)
    var body: some Scene {
        WindowGroup {
            
            
            ContentView(selectedAccount: Bindable(viewController).selectedAccount,
                        selectedEntry: Bindable(viewController).selectedEntry)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environment(viewController)
                .onAppear {
                    // -- DEBUG
                    print(URL.applicationSupportDirectory.path(percentEncoded: false))
                    //print(PersistenceController.sharedViewContext.registeredObjects)
                }
                .environmentObject(viewController.selectedAccount ?? .placeholder)
            
            
        }
        .commands {
            CommandGroup(before: .importExport) {
                Button("Add files to Ledger...") {
                    viewController.fileImporterIsPresented = true
                }
            }
            CommandMenu("Table") {
                Button("Add Row Above") {
                    if let selectedAccount = viewController.selectedAccount {
                        CDController.createEntry(for: selectedAccount, above: viewController.selectedEntry)
                    }
                }
                
                Button("Add Row Below") {
                    if let selectedAccount = viewController.selectedAccount {
                        CDController.createEntry(for: selectedAccount, below: viewController.selectedEntry)
                    }
                }
                
                Divider()
                
                Button("Delete Row") {
                    if let selectedEntry = viewController.selectedEntry {
                        PersistenceController.shared.viewContext.perform {
                            CDController.delete(selectedEntry, useRoundedTotals: viewController.useRoundedTotals) { success, newSelf in
                                guard success else { return }
                                viewController.selectedEntry = newSelf
                            }
                        }
                    }
                }
                .keyboardShortcut(.deleteRow)
                
                Divider()
                
                Menu("Jump To") {
                    Button("Top") {
                        viewController.jumpDestination = .top
                    }
                    .keyboardShortcut(.jumpToTop)
                    Button("Bottom") {
                        viewController.jumpDestination = .bottom
                    }
                    .keyboardShortcut(.jumpToBottom)
                    
                    Button("Selection") {
                        viewController.jumpDestination = .selection
                    }
                    .keyboardShortcut(.jumpToSelection)
                    
                }
                
                Divider()
                
                Button("Zoom In") {
                    guard viewController.tableZoom != TableScale.allCases.last else { return }
                    viewController.tableZoom = viewController.tableZoom.advanced(by: 1)
                }
                .keyboardShortcut(KeyEquivalent("+"), modifiers: .command)
                
                Button("Zoom Out") {
                    guard viewController.tableZoom != TableScale.allCases.first else { return }
                    viewController.tableZoom = viewController.tableZoom.advanced(by: -1)
                }
                .keyboardShortcut(KeyEquivalent("-"), modifiers: .command)
                
            }
            
        }
        
    }
}
