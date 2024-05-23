//
//  AccountViewModel.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/20/24.
//

import SwiftUI
import Foundation

@Observable
class AccountViewModel {
    
    private(set) var accountName: String
    private(set) var accountEntries: [AccountEntry]
    
    var useRoundedTotals: Bool {
        didSet {
            updateRunningTotals()
        }
    }
    
    private(set) static var formatter: DateFormatter = DateFormatter()
    
    init() {
        do {
            self.accountEntries = try loadEntries(from: "2018-05-20-CreditCard", ofType: ".plist")
        }
        catch {
            fatalError("\(error)")
        }
        
        self.useRoundedTotals = false
        self.accountName = "Empty Account Name"
        updateRunningTotals()
    }

    func togglePostedStatus(for id: UUID) {
        guard let index = indexOf(id: id) else { return }
        
        accountEntries[index].posted.toggle()
        forceRedraw()
    }
    
    func insertNewEntryAfter(id: UUID) {
        guard let index = indexOf(id: id) else { return }
        
        accountEntries.insert(AccountEntry(), at: index + 1)
        updateRunningTotals()
        forceRedraw()
    }
    
    static func formattedDate(_ date: Date, _ format: String = "dd/MM") -> String {
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func replace(selected: AccountEntry.ID, with entry: AccountEntry) {
        guard let index = indexOf(id: selected) else { return }
        
        accountEntries[index] = entry
        updateRunningTotals()
    }
    
    func getFirstSelectedEntry(from selected: Set<AccountEntry.ID>) -> AccountEntry? {
        return accountEntries.first(where: { selected.contains($0.id) })
    }
    
    func swap(_ i: Int, _ j: Int) {
        accountEntries.swapAt(i, j)
        forceRedraw()
    }
    
    func forceRedraw() {
        accountEntries = accountEntries
    }
    
    func searchFor(_ notes: String) -> AccountEntry.ID? {
        return accountEntries.filter { $0.notes.lowercased().contains(notes.lowercased()) }.first?.id
    }
    
    func indexOf(id: UUID) -> Int? {
        return accountEntries.firstIndex(where: { $0.id == id })
    }
    
    func updateRunningTotals(from id: UUID? = nil) {
        
        var previousTotal: Double
        let startIndex: Int
        
        if let id = id,
           let index = indexOf(id: id)
        {
            previousTotal = accountEntries[index].runningTotal
            startIndex = index
        } else {
            previousTotal = 0
            startIndex = 0
        }
        
        for i in startIndex..<accountEntries.count {
            let current = accountEntries[i]
            
            current.runningTotal = previousTotal + current.debitAmount - current.creditAmount
            
            if useRoundedTotals {
                current.runningTotal.round(.up)
            }
            
            previousTotal = current.runningTotal
        }
        
        forceRedraw()
    }
}
