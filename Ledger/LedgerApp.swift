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
    // Contains the managedObjectContext
    @State private var viewController = ViewController(viewContext: PersistenceController.sharedViewContext)
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.sharedViewContext)
                .environment(viewController)
                .onAppear {
                    // -- DEBUG
                    print(URL.applicationSupportDirectory.path(percentEncoded: false))
                    //print(PersistenceController.sharedViewContext.registeredObjects)
                }
        }
        
        
    }
}
