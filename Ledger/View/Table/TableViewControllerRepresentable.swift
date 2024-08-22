//
//  TableViewControllerRepresentable.swift
//  Ledger
//
//  Created by Avi Sanchez on 7/17/24.
//

import Foundation
import SwiftUI

struct TableViewControllerRepresentable: NSViewControllerRepresentable {
    
    @Environment(SearchController.self)
    var searchController
    
    @Environment(ViewController.self)
    var viewController
    
    @Environment(\.isSearching)
    var isSearching
    
    @Environment(\.dismissSearch)
    var dismissSearch
    
    @Environment(\.managedObjectContext)
    var viewContext
    
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

        if viewController.selectedAccount != context.coordinator.selectedAccount {
            context.coordinator.selectedAccount = viewController.selectedAccount
            FRC.main.updateFetch(for: viewController.selectedAccount)
            viewContext.perform {
                tableViewController._updateRunningTotals()
            }
            
            tableViewController.tableView.scrollToBottom()
        }
        
        if viewController.selectedEntry != context.coordinator.selectedEntry {
            context.coordinator.selectedEntry = viewController.selectedEntry
            tableViewController.updateSelection()
        }
        
        if viewController.useRoundedTotals != context.coordinator.useRoundedTotals {
            context.coordinator.useRoundedTotals = viewController.useRoundedTotals
            tableViewController._updateRunningTotals()
        }
        
        if isSearching != context.coordinator.isSearching {
            context.coordinator.isSearching = isSearching
            if !isSearching {
                FRC.main.updateFetch(for: viewController.selectedAccount)
            }
        }

//        if viewController.tableScale != context.coordinator.tableScale {
//            context.coordinator.tableScale = viewController.tableScale
//            tableViewController.tableView.reloadData()
//        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    
    class Coordinator: NSObject, TableViewControllerDelegate {
        var parent: TableViewControllerRepresentable
        
        var viewContext: NSManagedObjectContext { parent.viewContext }
        var selectedAccount: CDAccount?
        var selectedEntry: CDAccountEntry?
        var useRoundedTotals: Bool
        var tableScale: TableScale
        var isSearching: Bool
                
        init(_ parent: TableViewControllerRepresentable) {
            self.parent = parent
            self.useRoundedTotals = false
            self.tableScale = .regular
            self.isSearching = false
        }
        
        func didSelectRow(_ entry: CDAccountEntry?) {
            parent.viewController.selectedEntry = entry
        }
        
        func dismissSearch() {
            parent.dismissSearch.callAsFunction()
        }

    }
}
