//
//  TableViewControllerRepresentable.swift
//  Ledger
//
//  Created by Avi Sanchez on 7/17/24.
//

import Foundation
import SwiftUI

struct TableViewControllerRepresentable: NSViewControllerRepresentable {
    
    @Binding var selectedAccount: CDAccount?
    @Binding var selectedEntry: CDAccountEntry?
    @Binding var useRoundedTotals: Bool
    
    func makeNSViewController(context: Context) -> NSViewController {
        let storyboard = NSStoryboard(name: "TableView",
                                      bundle: Bundle.main)
        let viewController = storyboard.instantiateController(withIdentifier: "specialsauce") as! TableViewController
        
        // code breaks without making this async
        DispatchQueue.main.async {
            viewController.delegate = context.coordinator
        }
        
        return viewController
    }
    
    // In order for this function to be called, the binding variables of this class must be referenced in the function. This function is smart.
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
        guard let tableViewController = nsViewController as? TableViewController
        else { return }

        if selectedAccount != context.coordinator.selectedAccount {
            context.coordinator.selectedAccount = selectedAccount
            tableViewController.updateFetch(for: selectedAccount)
            tableViewController.updateRunningTotals(from: selectedAccount?.firstEntry)
        }
        
        if useRoundedTotals != context.coordinator.useRoundedTotals {
            context.coordinator.useRoundedTotals = useRoundedTotals
            tableViewController.updateRunningTotals(from: selectedAccount?.firstEntry)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    
    class Coordinator: NSObject, TableViewControllerDelegate {
        var parent: TableViewControllerRepresentable
        
        var selectedAccount: CDAccount?
        var useRoundedTotals: Bool
                
        init(_ parent: TableViewControllerRepresentable) {
            self.parent = parent
            self.useRoundedTotals = false
        }
                
        func didSelectRow(_ entry: CDAccountEntry?) {
            parent.selectedEntry = entry
        }
    }
}
