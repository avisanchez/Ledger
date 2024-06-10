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
    private let container: ModelContainer
        
    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: container.mainContext)
        }
        .modelContainer(container)
        
    }
    
    init() {
        do {
            self.container = try ModelContainer(for: Account.self, AccountEntry.self)
            print(URL.applicationSupportDirectory.path(percentEncoded: false))
        } catch {
            fatalError("Failed to create ModelContainer for Account, AccountEntry: \(error.localizedDescription)")
        }
    }
}
