//
//  ViewController.swift
//  Ledger
//
//  Created by Avi Sanchez on 6/11/24.
//

import Foundation
import CoreData
import Observation
import SwiftUI

enum TableScale: CaseIterable, Identifiable {
    var id: UUID { UUID() } 
    
    case xsmall
    case small
    case regular
    case large
    case xlarge
    case xxlarge
    case xxxlarge
}

@Observable
class ViewController {

// -- PUBLIC VARIABLES
    
    // -- Untracked
    @ObservationIgnored
    let viewContext: NSManagedObjectContext
    
    // -- Observed/Tracked
    var selectedAccount: CDAccount?
    
    var selectedEntry: CDAccountEntry?
        
    var useRoundedTotals: Bool = false
    
    var jumpDestination: TableViewController.JumpDestination = .none
    
    var fileImporterIsPresented: Bool = false
    
    var tableZoom: TableScale = .regular
    
//    var canUndo: Bool {
//        viewContext.undoManager?.canUndo ?? false
//    }
//    
//    var canRedo: Bool {
//        viewContext.undoManager?.canRedo ?? false
//    }
    
    enum AppState {
        case importingFile
        case deletingAccount
        case creatingAccount
        case none
    }
    
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
        } else {
            selectedEntry = newEntry
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
        if entry == selectedEntry {
            selectedEntry = nil
        }
        _delete(entry)
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
        viewContext.perform {
            self.viewContext.undo()
            self.viewContext.attemptSave()
        }
    }
    
    
    func redo() {
        viewContext.perform {
            self.viewContext.redo()
            self.save()
        }
    }
    
    
    // -- PRIVATE METHODS --
    
    private func _delete(_ account: CDAccount) {
        viewContext.perform {
            self.viewContext.delete(account)
            self.save()
        }
    }
    
    
    private func _delete(_ entry: CDAccountEntry) {
        viewContext.perform {
            self._link(entry.previous, entry.next)
            self.viewContext.delete(entry)
            self.save()
        }
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
