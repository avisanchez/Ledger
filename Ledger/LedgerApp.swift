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
    @State private var viewController = ViewController(viewContext: PersistenceController.managedObjectContext)
    
    var body: some Scene {
        
        WindowGroup {
            
                
            ContentView(selectedAccount: Bindable(viewController).selectedAccount,
                        selectedEntry: Bindable(viewController).selectedEntry)
                .environment(\.managedObjectContext, PersistenceController.managedObjectContext)
                .environment(viewController)
                .onAppear {
                    // -- DEBUG
                    print(URL.applicationSupportDirectory.path(percentEncoded: false))
                    //print(PersistenceController.sharedViewContext.registeredObjects)
                }
            
            
            
            
            
        }
        
        
        
    }
}
