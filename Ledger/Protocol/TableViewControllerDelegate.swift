//
//  TableViewControllerDelegate.swift
//  Ledger
//
//  Created by Avi Sanchez on 7/22/24.
//

import Foundation
import CoreData


protocol TableViewControllerDelegate: AnyObject {
    var viewContext: NSManagedObjectContext {
        get
    }
    
    var selectedAccount: CDAccount? {
        get
    }
    
    var selectedEntry: CDAccountEntry? {
        get
        set
    }
    
    var useRoundedTotals: Bool {
        get
    }
    
    var tableScale: TableScale {
        get
        set
    }
    
    var isSearching: Bool {
        get
        set
    }
    
    func didSelectRow(_ entry: CDAccountEntry?)
    
    func dismissSearch()
}
