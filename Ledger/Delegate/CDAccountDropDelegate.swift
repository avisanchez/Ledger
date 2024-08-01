//
//  AccountDropDelegate.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/29/24.
//

import SwiftUI
import Foundation

struct AccountDropDelegate: DropDelegate {
    
    let account: CDAccount
    @Binding var accounts: [CDAccount]
    @Binding var draggedAccount: CDAccount?

    
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        guard let draggedAccount else { return nil }
        
        if draggedAccount != account {
            guard let from = accounts.firstIndex(of: draggedAccount) else { return nil }
            guard let to = accounts.firstIndex(of: account) else { return nil }
            withAnimation {
                accounts.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
        
        return DropProposal(operation: .move)
    }

    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    
}
