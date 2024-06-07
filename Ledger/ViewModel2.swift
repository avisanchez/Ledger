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
    
    var selectedAccount: Account.ID?
    
    var allData: [Account] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
                
        do {
            var descriptor = FetchDescriptor<Account>()
            descriptor.sortBy = [SortDescriptor(\.name)]
            descriptor.relationshipKeyPathsForPrefetching = [\.entries]
            
            allData = try fetch(descriptor)
        } catch {
            fatalError("\(error.localizedDescription)")
        }
    }
    
    func createAccount() {
        modelContext.insert(Account(name: "New Account"))
    }
    
    func deleteAccount(id: UUID?) {
        guard let id else { return }
        
        do {
            try modelContext.delete(model: Account.self, 
                                    where: #Predicate<Account> { $0.id == id })
            
        } catch {
            fatalError("Failed to delete account: \(error.localizedDescription)")
        }
    }
    
    
    func fetchIdentifiers<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [PersistentIdentifier] {
        return try modelContext.fetchIdentifiers(descriptor)
    }
    
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        return try modelContext.fetch(descriptor)
    }
}
