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
    
    var useRoundedTotals: Bool {
        get
    }
    
    func didSelectRow(_ entry: CDAccountEntry?)
}
