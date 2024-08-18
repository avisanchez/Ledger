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
    private var searchController
    
    @Environment(ViewController.self)
    private var viewController
    
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
            FRC.shared.updateFetch(for: viewController.selectedAccount)
            tableViewController.updateRunningTotals()
            tableViewController.jump(to: .bottom)
        }
        
        if viewController.selectedEntry != context.coordinator.selectedEntry {
            context.coordinator.selectedEntry = viewController.selectedEntry
            tableViewController.updateSelection()
        }
        
        if viewController.useRoundedTotals != context.coordinator.useRoundedTotals {
            context.coordinator.useRoundedTotals = viewController.useRoundedTotals
            tableViewController.updateRunningTotals()
        }
        
        if viewController.jumpDestination != context.coordinator.jumpDestination {
            context.coordinator.jumpDestination = viewController.jumpDestination
            tableViewController.jump(to: viewController.jumpDestination)
            viewController.jumpDestination = .none
        }
        
        if viewController.tableZoom != context.coordinator.scale {
            context.coordinator.scale = viewController.tableZoom
            tableViewController.tableView.reloadData()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    
    class Coordinator: NSObject, TableViewControllerDelegate {
        var parent: TableViewControllerRepresentable
        
        var selectedAccount: CDAccount?
        var selectedEntry: CDAccountEntry?
        var useRoundedTotals: Bool
        var jumpDestination: TableViewController.JumpDestination
        var scale: TableScale
                
        init(_ parent: TableViewControllerRepresentable) {
            self.parent = parent
            self.useRoundedTotals = false
            self.jumpDestination = .none
            self.scale = .regular
        }
        
        func didSelectRow(_ entry: CDAccountEntry?) {
            parent.viewController.selectedEntry = entry
        }

    }
}
