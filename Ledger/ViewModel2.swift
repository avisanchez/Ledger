//
//  ViewModel2.swift
//  Ledger
//
//  Created by Avi Sanchez on 6/5/24.
//

import Foundation
import SwiftData

@Observable
class ViewModel2 {
    private let modelContext: ModelContext
    
    var selectedAccount: Account?
    var selectedEntries: Set<AccountEntry.ID>
    
    var firstSelectedEntry: (Int, AccountEntry)? {
        guard let selectedAccount else { return nil }

        return selectedAccount.entries.enumerated().first(where: {
            selectedEntries.contains($0.element.id)
        })
    }
            
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.selectedEntries = []
    }
    
    func createAccount() {
        modelContext.insert(Account(name: "New Account"))
    }
    
    func deleteAccount(id: Account.ID?) {
        guard let id else { return }
        
        do {
            try modelContext.delete(model: Account.self, 
                                    where: #Predicate<Account> { $0.id == id })
            
        } catch {
            fatalError("Failed to delete account: \(error.localizedDescription)")
        }
    }
    
    func createEntry() {
        guard let selectedAccount else { return }
        
        let newEntry = AccountEntry()
        newEntry.notes = "\(newEntry.id)"

        if let firstSelectedEntry  {
            print("Array before: \(selectedEntriesAsString)")
            selectedAccount.entries.insert(newEntry, at: firstSelectedEntry.0)
            print("Array after: \(selectedEntriesAsString)")
        } else {
            print("appending entry to list")
            selectedAccount.entries.append(newEntry)
        }
    }
    
    // DEBUG
    private var selectedEntriesAsString: String {
        guard let selectedAccount else { return "" }
        
        var formattedString: String = "["
        for entry in selectedAccount.entries {
            formattedString += "\(entry.notes), "
        }
        formattedString.removeLast(2)
        formattedString += "]"
        return formattedString
    }
    
    
    func fetchIdentifiers<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [PersistentIdentifier] {
        return try modelContext.fetchIdentifiers(descriptor)
    }
    
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        return try modelContext.fetch(descriptor)
    }
}
