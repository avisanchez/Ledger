//
//  Helper.swift
//  Ledger
//
//  Created by Avi Sanchez on 7/30/24.
//

import Foundation
import CoreData


final class CDController {
    
    /*
     
     */
    static func resetSortOrder(from firstEntry: CDAccountEntry) {
        var sortOrder = 0
        
        var current: CDAccountEntry? = firstEntry
        while (current != nil) {
            current?.sortOrder = sortOrder
            sortOrder += Constants.sortOrderSpacing
            current = current?.next
        }
    }
    
    static func updateRunningTotals(from start: CDAccountEntry?, to end: CDAccountEntry? = nil, useRoundedTotals: Bool) {
        guard let start
        else { return }
    
        var current: CDAccountEntry? = start
        
        var runningTotal: Double = start.previous?.runningTotal ?? 0
        
        while (current != nil) {
            
            guard let current_safe = current else { break }
            
            if useRoundedTotals {
                runningTotal += current_safe.debitAmount.rounded(.up) - current_safe.creditAmount.rounded(.down)
            } else {
                runningTotal += current_safe.debitAmount - current_safe.creditAmount
            }
            
            current_safe.runningTotal = runningTotal
            current = current_safe.next
            
            if current_safe == end { break }
        }
    }
    
    static func moveEntry(_ entryToMove: CDAccountEntry, below entryToInsertAt: CDAccountEntry) {
        _link(entryToMove.previous, entryToMove.next)
        insertEntry(entryToMove, below: entryToInsertAt)
    }
    
    static func moveEntry(_ entryToMove: CDAccountEntry, above entryToInsertAt: CDAccountEntry) {
        _link(entryToMove.previous, entryToMove.next)
        insertEntry(entryToMove, above: entryToInsertAt)
    }
    
    static func insertEntry(_ newEntry: CDAccountEntry, below oldEntry: CDAccountEntry) {
        _link(newEntry, oldEntry.next)
        _link(oldEntry, newEntry)
        
        _calculateSortOrder(for: newEntry)
    }
    
    static func insertEntry(_ newEntry: CDAccountEntry, above oldEntry: CDAccountEntry) {
        _link(oldEntry.previous, newEntry)
        _link(newEntry, oldEntry)
        
        _calculateSortOrder(for: newEntry)
    }
    
    /*
     Creates a new entry above the specified entry. If 'entry' is nil, a new entry is created in the first position.
     */
    @discardableResult
    static func createEntry(for account: CDAccount, above entry: CDAccountEntry?) -> CDAccountEntry? {
        guard let viewContext = account.managedObjectContext else { return nil }
        
        let firstEntry = account.firstEntry
        
        let newEntry = CDAccountEntry(context: viewContext, owner: account)
        
        if let entry {
            _link(entry.previous, newEntry)
            _link(newEntry, entry)
        } else if let firstEntry {
            _link(newEntry, firstEntry)
        }
        
        _calculateSortOrder(for: newEntry)
        
        viewContext.attemptSave()
        
        return newEntry
    }
    
    /*
     Creates a new entry below the specified entry. If 'entry' is nil, a new entry is created in the last position.
     */
    @discardableResult
    static func createEntry(for account: CDAccount, below entry: CDAccountEntry?) -> CDAccountEntry? {
        guard let viewContext = account.managedObjectContext else { return nil }
        
        let lastEntry = account.lastEntry
        
        let newEntry = CDAccountEntry(context: viewContext, owner: account)
        
        if let entry {
            _link(newEntry, entry.next)
            _link(entry, newEntry)
        } else if let lastEntry {
            _link(lastEntry, newEntry)
        }
        
        _calculateSortOrder(for: newEntry)
        
        viewContext.attemptSave()

        return newEntry
    }
    
    /*
     Deletes the entry from it's managed object context. The newSelf parameter of the completion handler represents the entry whose row index is now that of the deleted object. newSelf will be nil if the context cannot be established or if the deleted entry was the last remaining entry in the account (i.e. prev == next == nil).
     */
    static func delete(_ entry: CDAccountEntry, useRoundedTotals: Bool, completion: (_ success: Bool,
                                                             _ newSelf: CDAccountEntry?) -> Void) {
        
        guard let viewContext = entry.managedObjectContext else {
            return completion(false, nil)
        }
        
        let previous = entry.previous
        let next = entry.next
        
        _link(entry.previous, entry.next)
        
        var newSelf: CDAccountEntry?
        
        
        viewContext.delete(entry)
        
        if let next {
            updateRunningTotals(from: next, useRoundedTotals: useRoundedTotals)
            newSelf = next
        } else {
            newSelf = previous
        }
        
        viewContext.attemptSave()
        
        return completion(true, newSelf)
    }
    
    
    private static func _calculateSortOrder(for current: CDAccountEntry) {
        
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
    private static func _pushForward(_ current: CDAccountEntry) -> Int {
        
        guard let next = current.next else {
            current.sortOrder += Constants.sortOrderSpacing
            return current.sortOrder
        }
                
        if _hasSpaceBetween(current, next) {
            current.sortOrder = _average(current.sortOrder, next.sortOrder)
        } else {
            current.sortOrder = _average(current.sortOrder, _pushForward(next))
        }
        
        return current.sortOrder
    }
    
    private static func _link<T: NSManagedObject & Sortable>(_ object1: T?, _ object2: T?) {
        if var object1 {
            object1.next = object2
        } else if var object2 {
            object2.previous = object1
        }
    }
    
    private static let _average: (Int, Int) -> Int = { ($0 + $1) / 2 }

    private static let _hasSpaceBetween: (CDAccountEntry, CDAccountEntry) -> Bool = {
        return abs($1.sortOrder - $0.sortOrder) > 1
    }
    
    private init() {}
}



