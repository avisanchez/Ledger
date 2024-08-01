//
//  Helper.swift
//  Ledger
//
//  Created by Avi Sanchez on 7/30/24.
//

import Foundation
import CoreData


class CDHelper {
    
    static func resetSortOrder(from firstEntry: CDAccountEntry) {
        var sortOrder = 0
        
        var current: CDAccountEntry? = firstEntry
        while (current != nil) {
            current?.sortOrder = sortOrder
            sortOrder += Constants.sortOrderSpacing
            current = current?.next
        }
    }
    
    static func moveEntry(_ entryToMove: CDAccountEntry, below entryToInsertAt: CDAccountEntry) {
        Self._link(entryToMove.previous, entryToMove.next)
        Self.insertEntry(entryToMove, below: entryToInsertAt)
    }
    
    static func moveEntry(_ entryToMove: CDAccountEntry, above entryToInsertAt: CDAccountEntry) {
        Self._link(entryToMove.previous, entryToMove.next)
        Self.insertEntry(entryToMove, above: entryToInsertAt)
    }
    
    static func insertEntry(_ newEntry: CDAccountEntry, below oldEntry: CDAccountEntry) {
        Self._link(newEntry, oldEntry.next)
        Self._link(oldEntry, newEntry)
        
        _calculateSortOrder(for: newEntry)
    }
    
    static func insertEntry(_ newEntry: CDAccountEntry, above oldEntry: CDAccountEntry) {
        Self._link(oldEntry.previous, newEntry)
        Self._link(newEntry, oldEntry)
        
        _calculateSortOrder(for: newEntry)
    }
    
    static func createEntry(for account: CDAccount, withSelection selectedEntry: CDAccountEntry?, autosave: Bool = true) -> CDAccountEntry? {
        guard let viewContext = account.managedObjectContext else { return nil }
        
        let newEntry = CDAccountEntry(context: viewContext, owner: account)
        
        if let selectedEntry {
            /*
             Order here matters!
             
             DON'T DO THE FOLLOWING
             __link(selectedAccount, newAccount)
             __link(newAccount, selectedAccount.next)
             
             The above statement fails because selectedAccount.next will point to newAccount, in turn _linking newAccount to itself
             */
            
            Self._link(newEntry, selectedEntry.next)
            Self._link(selectedEntry, newEntry)
        }
        
        Self._calculateSortOrder(for: newEntry)

        if autosave {
            try? viewContext.save()
        }
        
        return newEntry
    }
    
    private static func _calculateSortOrder(for current: CDAccountEntry) {
        
        // check if this is the first entry
        guard let previous = current.previous else {
            if let next = current.next, next.sortOrder == 0 {
                Self._pushForward(next)
            }
            
            current.sortOrder = 0
            return
        }
        
        // check if this is the last entry
        guard let next = current.next else {
            current.sortOrder = previous.sortOrder + Constants.sortOrderSpacing
            return
        }
        
        
        current.sortOrder = Self._average(previous.sortOrder, next.sortOrder)
        
        if previous.sortOrder == current.sortOrder {
            current.sortOrder = Self._average(previous.sortOrder, _pushForward(next))
        }
    }
    
    @discardableResult
    private static func _pushForward(_ current: CDAccountEntry) -> Int {
        
        guard let next = current.next else {
            current.sortOrder += Constants.sortOrderSpacing
            return current.sortOrder
        }
                
        if Self._hasSpaceBetween(current, next) {
            current.sortOrder = Self._average(current.sortOrder, next.sortOrder)
        } else {
            current.sortOrder = Self._average(current.sortOrder, _pushForward(next))
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



