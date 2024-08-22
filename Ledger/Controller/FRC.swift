//
//  FRC.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/7/24.
//

import Foundation
import CoreData
import AppKit

final class FRC: NSFetchedResultsController<CDAccountEntry>, NSFetchedResultsControllerDelegate {
    
    static let main = FRC()
    
    static let search = FRC()
    
    var tableView: NSTableView? {
        didSet { tableView?.reloadData() }
    }
   
    var firstObject: CDAccountEntry? { self.fetchedObjects?.first }
    var lastObject: CDAccountEntry? { self.fetchedObjects?.last }
    
    func updateFetch(for newAccount: CDAccount?) {
        
        var predicate: NSPredicate
        if let newAccount {
            predicate = NSPredicate(format: "owner == %@", newAccount)
        } else {
            predicate = .FALSE
        }
        
        updateFetch(using: predicate)
    }
    
    func updateFetch(using predicate: NSPredicate) {
        self.fetchRequest.predicate = predicate
        
        do {
            try self.performFetch()
        } catch {
            fatalError("Failed to perform fetch: \(error)")
        }
        
        tableView?.reloadData()
    }
    
    /*
     Ensures table view does not crash when inserting or deleting large amounts of data. Batches are not atomic causing out-of-bound exceptions.
     
     Bug documented & fix perscribed in (scroll to bottom):
     https://samwize.com/2018/11/16/guide-to-nsfetchedresultscontroller-with-nstableview-macos/
     */
    private var _rowDeletes: IndexSet = []
    private var _rowInserts: IndexSet = []
    private var _rowUpdates: IndexSet = []
    private var _rowMoves: [(from: Int, to: Int)] = []
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        _rowDeletes = []
        _rowInserts = []
        _rowUpdates = []
        _rowMoves = []
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let tableView else  { return }
        tableView.beginUpdates()
        tableView.removeRows(at: _rowDeletes, withAnimation: .slideUp)
        tableView.insertRows(at: _rowInserts, withAnimation: .slideDown)
        _rowMoves.forEach { tableView.moveRow(at: $0.0, to: $0.1) }
        _rowUpdates.forEach {
            tableView.reloadData(forRowIndexes: [$0],
                                 columnIndexes: tableView.columnIndexes)
        }
        tableView.endUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath else { return }
            _rowInserts.insert(newIndexPath.item)
            break
        case .delete:
            guard let indexPath else { return }
             _rowDeletes.insert(indexPath.item)
            break
        case .update:
            if let indexPath {
                _rowUpdates.insert(indexPath.item)
            }
            if let newIndexPath {
                _rowUpdates.insert(newIndexPath.item)
            }             
            break
        case .move:
            guard let indexPath, let newIndexPath else { return }
            _rowMoves.append((from: indexPath.item, to: newIndexPath.item))
            break
        @unknown default:
            break
        }
    }
    
    private override init() {
        let request = CDAccountEntry.fetchRequest()
        request.sortDescriptors = [.sortOrder]
        let moc = PersistenceController.shared.viewContext

        super.init(fetchRequest: request, 
                   managedObjectContext: moc,
                   sectionNameKeyPath: nil,
                   cacheName: nil)
        self.delegate = self
        
        do {
            try self.performFetch()
            tableView?.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
}
