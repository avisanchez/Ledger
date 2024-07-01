//
//  ViewController.swift
//  Ledger
//
//  Created by Avi Sanchez on 6/11/24.
//

import Foundation
import CoreData
import Observation

@Observable
class ViewController {

// -- PUBLIC VARIABLES
    
    // -- Untracked
    @ObservationIgnored
    let viewContext: NSManagedObjectContext
    
    // -- Observed/Tracked
    var selectedAccount: CDAccount?
    var selectedEntry: CDAccountEntry?
    
    var useRoundedTotals: Bool {
        didSet {
            guard let selectedAccount else { return }
            // TODO: Implement rounding totals
        }
    }
    
    // -- Computed
    var firstAccount: CDAccount? {
        return get(CDAccount.self, at: 0)
    }
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.useRoundedTotals = false
        self.selectedAccount = firstAccount

        viewContext.undoManager = UndoManager()
    }
    
    
    func createAccount(withName name: String, startingBalance: Double? = nil) {
        
        let newAccount = CDAccount(context: viewContext)
        newAccount.name = name
        
        if let selectedAccount {
            newAccount.sortOrder = _calculateSortOrder(insertingAfter: selectedAccount)
            
            /*
             Order here (and later in the code) matters!
             
             DON'T DO THE FOLLOWING
             _link(selectedAccount, newAccount)
             _link(newAccount, selectedAccount.next)
             
             The above statement fails because selectedAccount.next will point to newAccount, in turn linking newAccount to itself
             */
            _link(newAccount, selectedAccount.next)
            _link(selectedAccount, newAccount)
        } else {
            newAccount.sortOrder = 0
        }
        
        if let startingBalance {
            createEntry(for: newAccount)
        }
        
        save()
        
        selectedAccount = newAccount
    }
    
    
    func createEntry(for account: CDAccount) -> CDAccountEntry {
        
        let newEntry = CDAccountEntry(context: viewContext, owner: account)
        
        if let selectedEntry {
            newEntry.sortOrder = _calculateSortOrder(insertingAfter: selectedEntry)
            
            /*
             Order here (and later in the code) matters!
             
             DON'T DO THE FOLLOWING
             _link(selectedAccount, newAccount)
             _link(newAccount, selectedAccount.next)
             
             The above statement fails because selectedAccount.next will point to newAccount, in turn linking newAccount to itself
             */
            _link(newEntry, selectedEntry.next)
            _link(selectedEntry, newEntry)
        } else {
            newEntry.sortOrder = 0
        }
        
        save()
        
        return newEntry
        //selectedEntry = newEntry
    }
    
    func createFirstAccountEntry(for account: CDAccount, startingBalance: Double) {
        let newAccount = createEntry(for: account)
        newAccount.notes = "STARTING_BALANCE"
        if startingBalance > 0 {
            newAccount.debitAmount = abs(startingBalance)
        } else {
            newAccount.creditAmount = abs(startingBalance)
        }
    }
    
    
    func delete(_ account: CDAccount) {
        if selectedAccount == account { selectedAccount = account.previous }
        _delete(account)
    }
    
    
    func delete(_ entry: CDAccountEntry) {
        if selectedEntry == entry { selectedEntry = entry.previous }
        _delete(entry)
    }
    
    
    func updateRoundedTotals(for account: CDAccount) {
        //account.updateRunningTotals(useRoundedTotals)
    }
    
    
    func get<T: NSManagedObject & Sortable>(_ type: T.Type, at indicies: Int...) -> [T]? {
        let request = T.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        
        do {
            guard let fetchedObjects = try viewContext.fetch(request) as? [T] else {
                fatalError("DEBUG: Failed to transform objects")
            }
            
            guard indicies.allSatisfy( { 0 <= $0 && $0 <= fetchedObjects.count } ) else {
                fatalError("DEBUG: Index out of bounds")
            }
            
            return fetchedObjects.enumerated().filter { indicies.contains($0.offset) }
                .map { $0.element }
        } catch {
            fatalError("DEBUG: Failed to fetch objects: \(error)")
        }
    }
    
    
    func get<T: NSManagedObject & Sortable>(_ type: T.Type, at index: Int) -> T? {
        let result: [T]? = get(type, at: index)
        
        if let result, result.count > 1 {
            fatalError("DEBUG: More than one object detected at index \(index)")
        }
        
        return result?.first
    }
    
    
    func move<T: NSManagedObject & Sortable>(_ type: T.Type, _ startIndex: Int, to endIndex: Int) {
        
        guard startIndex != endIndex
        else { return }
        
        let moveForward: Bool = startIndex < endIndex
        
        guard let items = get(T.self, at: startIndex, moveForward ? endIndex - 1 : endIndex) else { return }
        
        guard var itemToMove = moveForward ? items.first : items.last,
              let itemToInsertAt = moveForward ? items.last : items.first
        else {
            fatalError("DEBUG: Failed to get start and end items")
        }
        
        // Remove item from linked list
        if var previous = itemToMove.previous {
            previous.next = itemToMove.next
        } else {
            itemToMove.next?.previous = nil
        }
        
        // Insert item into linked list
        if moveForward {
            itemToMove.sortOrder = _calculateSortOrder(insertingAfter: itemToInsertAt)
            _link(itemToMove, itemToInsertAt.next)
            _link(itemToInsertAt, itemToMove)
        } else {
            if endIndex == 0 {
                if itemToInsertAt.sortOrder == 0 {
                    _offsetSubsequentItems(startingFrom: itemToInsertAt)
                }
                
                itemToMove.sortOrder = 0
            } else {
                itemToMove.sortOrder = _calculateSortOrder(insertingAfter: itemToInsertAt.previous!)
            }
            _link(itemToInsertAt.previous, itemToMove)
            _link(itemToMove, itemToInsertAt)
        }
        
        save()
    }
    
    func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [NSFetchRequestResult] {
        try viewContext.fetch(request)
    }
    
    
    func save() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
            print("DEBUG: Save successful")
        } catch {
            fatalError("DEBUG: Save failed: \(error.localizedDescription)")
        }
    }
    
    
    func undo() {
        viewContext.undo()
        save()
    }
    
    
    func redo() {
        viewContext.redo()
        save()
    }
    
    
    // -- PRIVATE METHODS --
    
    private func _calculateSortOrder<T: Sortable>(insertingAfter item: T) -> Double {
        let TOL = 1e-5
        
        var sortOrder: Double
        
        if let nextItem = item.next {
            sortOrder = (item.sortOrder + nextItem.sortOrder) / 2
            
            if abs(sortOrder - nextItem.sortOrder) < TOL {
                _offsetSubsequentItems(startingFrom: nextItem)
                return _calculateSortOrder(insertingAfter: item)
            }
        } else {
            sortOrder = item.sortOrder + 1
        }
        
        return sortOrder
    }
    
    
    private func _delete<T: NSManagedObject & Sortable>(_ object: T) {
        _link(object.previous, object.next)
        viewContext.delete(object)
        save()
    }
    
    
    private func _link<T: NSManagedObject & Sortable>(_ object1: T?, _ object2: T?) {
        if var object1 {
            object1.next = object2
        } else if var object2 {
            object2.previous = object1
        }
    }
    
    
    private func _offsetSubsequentItems<T: Sortable>(by offset: Double = 1, startingFrom item: T) {
        var current: T? = item
        
        while current != nil {
            current?.sortOrder += offset
            current = current?.next
        }
    }
    
    
    // -- DEBUG --
    func printRegisteredObjects() {
        print(viewContext.registeredObjects)
    }
}
