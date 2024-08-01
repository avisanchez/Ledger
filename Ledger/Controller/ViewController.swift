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
    
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        
        viewContext.undoManager = UndoManager()
    }
    
    
    func createAccount(name: String, startingBalance: Double? = nil) {
        
        let newAccount = CDAccount(context: viewContext, name: name)
        
        if let startingBalance {
            createEntry(for: newAccount, startingBalance: startingBalance)
        }
        
        save()
        
        selectedAccount = newAccount
    }
    
    
    func createEntry(for account: CDAccount) -> CDAccountEntry {
        
        let newEntry = CDAccountEntry(context: viewContext, owner: account)
        
        if let selectedEntry {
            /*
             Order here matters!
             
             DON'T DO THE FOLLOWING
             _link(selectedAccount, newAccount)
             _link(newAccount, selectedAccount.next)
             
             The above statement fails because selectedAccount.next will point to newAccount, in turn linking newAccount to itself
             */
            
            _link(newEntry, selectedEntry.next)
            _link(selectedEntry, newEntry)
        }
        
        calculateSortOrder(for: newEntry)

        save()
        
        return newEntry
    }
    
    func calculateSortOrder(for current: CDAccountEntry) {
        
        // check if this is the first entry
        guard let previous = current.previous else {
            if let next = current.next, next.sortOrder == 0 {
                _pushForward(next)
            }
            
            current.sortOrder = 0
            return
        }
        
        // check if this is the last entry
        guard let next = current.next else {
            current.sortOrder = previous.sortOrder + Constants.sortOrderSpacing
            return
        }
        
        
        current.sortOrder = _average(previous.sortOrder, next.sortOrder)
        
        if previous.sortOrder == current.sortOrder {
            current.sortOrder = _average(previous.sortOrder, _pushForward(next))
        }
    }
    
    @discardableResult
    func _pushForward(_ current: CDAccountEntry) -> Int {
        
        guard let next = current.next else {
            current.sortOrder += Constants.sortOrderSpacing
            return current.sortOrder
        }
                
        if _adjacent(current, next) {
            current.sortOrder = _average(current.sortOrder, _pushForward(next))
        } else {
            current.sortOrder = _average(current.sortOrder, next.sortOrder)
        }
        
        return current.sortOrder
    }
    
    
    // this may not work - just out of curiosity
    @discardableResult
    private func _push(_ current: CDAccountEntry, _ direction: PushDirection = .forward) -> Int {
        guard let other = (direction == .forward) ? current.next : current.previous else {
            current.sortOrder += direction == .forward ? +4 : -4
            return current.sortOrder
        }
        
        if _adjacent(current, other) {
            current.sortOrder = _average(current.sortOrder, _push(other, direction))
        } else {
            current.sortOrder = _average(current.sortOrder, other.sortOrder)
        }

        return current.sortOrder
    }
    
    private enum PushDirection {
        case forward
        case backward
    }
    
    
    func createEntry(for account: CDAccount, startingBalance: Double) {
        let newEntry = createEntry(for: account)
        newEntry.notes = "STARTING_BALANCE"
        if startingBalance > 0 {
            newEntry.debitAmount = abs(startingBalance)
        } else {
            newEntry.creditAmount = abs(startingBalance)
        }
    }
    
    
    func delete(_ account: CDAccount) {
        selectedAccount = nil
        selectedEntry = nil
        _delete(account)
    }
    
    
    func delete(_ entry: CDAccountEntry) {
        if selectedEntry == entry { selectedEntry = entry.previous }
        _delete(entry)
    }
    
    func get<T: NSManagedObject & Sortable>(_ type: T.Type, at indicies: Int...) -> [T]? {
        let request = T.fetchRequest()
        
        request.sortDescriptors = [.sortOrder]
        
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
            _link(itemToMove, itemToInsertAt.next)
            _link(itemToInsertAt, itemToMove)
        } else {
            _link(itemToInsertAt.previous, itemToMove)
            _link(itemToMove, itemToInsertAt)
        }
        
        save()
    }
    
    func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [NSFetchRequestResult] {
        try viewContext.fetch(request)
    }
    
    @discardableResult
    func save() -> Bool {
        guard viewContext.hasChanges else { return false }
        
        do {
            try viewContext.save()
            return true
        } catch {
            fatalError("DEBUG: Save failed: \(error.localizedDescription)")
            return false
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
    
    private func _delete(_ account: CDAccount) {
        viewContext.delete(account)
        save()
    }
    
    
    private func _delete(_ entry: CDAccountEntry) {
        _link(entry.previous, entry.next)
        viewContext.delete(entry)
        save()
    }
    
    
    private func _link<T: NSManagedObject & Sortable>(_ object1: T?, _ object2: T?) {
        if var object1 {
            object1.next = object2
        } else if var object2 {
            object2.previous = object1
        }
    }
    
    // -- DEBUG --
    func printRegisteredObjects() {
        print(viewContext.registeredObjects)
    }
    
    private let _average: (Int, Int) -> Int = { ($0 + $1) / 2 }
    private let _adjacent: (_ a: CDAccountEntry, _ b: CDAccountEntry) -> Bool = {
        abs($0.sortOrder - $1.sortOrder) == 1
    }
}
