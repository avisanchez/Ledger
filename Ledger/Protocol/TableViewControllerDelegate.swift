//
//  TableViewControllerDelegate.swift
//  Ledger
//
//  Created by Avi Sanchez on 7/22/24.
//

import Foundation


protocol TableViewControllerDelegate: AnyObject {
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
    
    var jumpDestination: TableViewController.JumpDestination {
        get
        set
    }
    
    var scale: TableScale {
        get
        set
    }
    
    func didSelectRow(_ entry: CDAccountEntry?)
}
