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
    @State var viewController = ViewController()

    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .onAppear {
                    // -- DEBUG
                    print(URL.applicationSupportDirectory.path(percentEncoded: false))
                    //print(PersistenceController.sharedViewContext.registeredObjects)
                }
        }
        .commands {
            CommandGroup(before: .importExport) {
                Button("Add files to Ledger...") {
                    viewController.fileImporterIsPresented = true
                }
            }
            
            TableCommands()
        }
        .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        .environment(viewController)
        .environmentObject(viewController.selectedAccount ?? .placeholder)
        
    }
}
