//
//  AccountViewModel.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/20/24.
//

import Foundation
import SwiftUI
import SwiftData


@Observable
class ViewModel {
    private let context: ModelContext
        
    private(set) var accountEntries: [AccountEntry]
    
    var selected: Set<AccountEntry.ID> {
        didSet { editableEntry = firstSelectedEntry() ?? AccountEntry() }
    }
    
    //var accounts: [Account] = []
    
    var editableEntry: AccountEntry
    
    // when this property is updated, all relative totals are recalculated
    var useRoundedTotals: Bool {
        didSet { updateRunningTotal() }
    }
    
    init(context: ModelContext) {
        self.context = context
        
        do {
            self.accountEntries = try loadEntries(from: "2018-05-20-CreditCard", ofType: ".plist")
        }
        catch {
            fatalError("\(error)")
        }
        
        self.useRoundedTotals = false
        self.selected = []
        self.editableEntry = AccountEntry()
        
        
        
        updateRunningTotal()
    }
    
    
//    func fetchAccount(id: UUID) throws -> [Account] {
//        var descriptor = FetchDescriptor<Account>(predicate: #Predicate<Account> {
//            $0.id == id
//        })
//        descriptor.relationshipKeyPathsForPrefetching = [\.entries]
//        
//        do {
//            let result = try context.fetch(descriptor)
//            
//            guard result.count == .zero else {
//                fatalError("Fetched single account for unique ID and recieved multiple matches.")
//            }
//            
//            return result
//        } catch {
//            
//        }
//    }
    
    func fetch<T: PersistentModel>(entityName: T) throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try context.fetch(descriptor)
    }

    func togglePostedStatus(for entry: AccountEntry) {
        guard let index = indexOf(id: entry.id) else { return }
        
        accountEntries[index].posted.toggle()
        forceRedraw()
    }
    
//    func insert(_ entryToInsert: AccountEntry, at id: UUID, offset: Offset = .same) {
//        guard let index = indexOf(id: id) else { return }
//
//        accountEntries.insert(entryToInsert, at: index + 1)
//        updateRunningTotal()
//        forceRedraw()
//    }
    
    func replace(_ oldEntry: AccountEntry, with newEntry: AccountEntry) {
        guard let index = indexOf(id: oldEntry.id) else { return }
        
        accountEntries[index] = newEntry
        updateRunningTotal(from: index)
    }
    
//    func firstSelectedEntry() -> (Int, AccountEntry)? {
//        for (i, entry) in accountEntries.enumerated() {
//            if selected.contains(entry.id) {
//                return (i, entry)
//            }
//        }
//        return nil
//    }
//
//    func lastSelectedEntry() -> (Int, AccountEntry)? {
//        for (i, entry) in accountEntries.reversed().enumerated() {
//            if selected.contains(entry.id) {
//                return (i, entry)
//            }
//        }
//        return nil
//    }
    
    func swapSelectedEntries(direction: Offset) {
        
        guard let firstIndex = firstSelectedEntryIndex(),
              let lastIndex = lastSelectedEntryIndex(),
              isValidIndex(direction == .up ? firstIndex - 1 : lastIndex + 1)
        else { return }
        
        let removeIndex = (direction == .up) ? firstIndex - 1 : lastIndex + 1
        let insertIndex = (direction == .up) ? lastIndex: firstIndex
        
        let tempEntry = accountEntries.remove(at: removeIndex)
        
        accountEntries.insert(tempEntry, at: insertIndex)
        
        updateRunningTotal(from: firstIndex - 1, to: lastIndex + 1)
        forceRedraw()
    }
    
    func searchFor(_ notes: String) -> AccountEntry.ID? {
        return accountEntries.filter { $0.notes.lowercased().contains(notes.lowercased()) }.first?.id
    }
    
    /*
     First-last function
     */
    
    func firstSelectedEntry() -> AccountEntry? {
        return accountEntries.first(where: { selected.contains($0.id) })
    }
    
    private func lastSelectedEntry() -> AccountEntry? {
        return accountEntries.last(where: { selected.contains($0.id) })
    }
    
    
    private func firstSelectedEntryIndex() -> Int? {
        return accountEntries.firstIndex(where: { selected.contains($0.id) })
    }
    
    private func lastSelectedEntryIndex() -> Int? {
        return accountEntries.lastIndex(where: { selected.contains($0.id) })
    }
    
    
    /*
     
     */
    
    private func updateRunningTotal(from startIndex: Int = 0, to endIndex: Int? = nil) {
        let endIndex = endIndex ?? accountEntries.count - 1
        
        guard isValidIndex(startIndex, endIndex) else { return }
        
        var previousTotal: Double
        
        if isValidIndex(startIndex - 1) {
            previousTotal = accountEntries[startIndex - 1].runningTotal
        } else {
            previousTotal = 0
        }
                
        for i in startIndex...endIndex {
            let current = accountEntries[i]
            
            current.runningTotal = previousTotal + current.debitAmount - current.creditAmount
            
            if useRoundedTotals { current.runningTotal.round(.up) }
            
            previousTotal = current.runningTotal
        }
        
        forceRedraw()
    }
    
    
    /*
     Causes scene redraw by updating the observed account entries list
    
     Note: This feels like a hack and should maybe be fixed later
     */
    private func forceRedraw() {
        accountEntries = accountEntries
    }
    
    /*
     Returns the first (and only) index matching the given ID
     */
    private func indexOf(id: UUID) -> Int? {
        return accountEntries.firstIndex(where: { $0.id == id })
    }
    
    /*
     Checks whether the indicies are all in the range [0, accountEntries.count)
     */
    private func isValidIndex(_ indicies: Int...) -> Bool {
        return indicies.allSatisfy { 0 <= $0 && $0 < accountEntries.count }
    }
    
    enum Offset {
        case up
        case down
        case none
    }
}


