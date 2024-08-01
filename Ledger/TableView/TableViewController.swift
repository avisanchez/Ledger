import Foundation
import AppKit
import SwiftUI

class TableViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    lazy var fetchedResultsController = {
        let request = CDAccountEntry.fetchRequest()
        request.sortDescriptors = [.sortOrder]
        let moc = PersistenceController.managedObjectContext
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: moc,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
            tableView.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        return controller
    }()
    
    // Connects this view controller to the coordinator to sync SwiftUI updates
    weak var delegate: TableViewControllerDelegate?
    
    /*
     Ensures table view does not crash when inserting or deleting large amounts of data. Batches are not atomic causing out-of-bound exceptions.
     
     Bug documented & fix perscribed in (scroll to bottom):
     https://samwize.com/2018/11/16/guide-to-nsfetchedresultscontroller-with-nstableview-macos/
     */
    private var _rowDeletes: IndexSet = []
    private var _rowInserts: IndexSet = []
    private var _rowUpdates: IndexSet = []
    private var _rowMoves: [(Int, Int)] = []

    func updateFetch(for newAccount: CDAccount?) {
        if let newAccount {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "owner == %@", newAccount)
        } else {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(value: false)
        }
        try? fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
    func updateRunningTotals(from testStart: CDAccountEntry?) {

        guard let delegate,
              let firstEntry = fetchedResultsController.fetchedObjects?.first,
              let testStart
        else { return }
    
        
        var current: CDAccountEntry? = testStart
        
        var runningTotal: Double = 0
        while (current != nil) {
            guard let current_safe = current else { break }
            
            if delegate.useRoundedTotals {
                runningTotal += current_safe.debitAmount.rounded(.up) - current_safe.creditAmount.rounded(.down)
            } else {
                runningTotal += current_safe.debitAmount - current_safe.creditAmount
            }
            
            current_safe.runningTotal = runningTotal
            current = current_safe.next
        }
    }
    
    override func viewDidLoad() {
        tableView.registerForDraggedTypes([.string])
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let delegate else { return }
        let selectedEntry = fetchedResultsController.fetchedObjects?[tableView.selectedRow]
        delegate.didSelectRow(selectedEntry)
    }
    
    
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        print("drag operation in motion")
        let pasteboard = NSPasteboardItem()
        pasteboard.setString("\(row)", forType: .string)
        return pasteboard
    }

    func tableView(_ tableView: NSTableView, validateDrop info: any NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        return .move
    }
    
    // This implementation assumes the table only allows single selection
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        print(dropOperation.rawValue)

        var oldIndexes = [Int]()
        
        info.draggingPasteboard.pasteboardItems?.forEach({ item in
            if let str = item.string(forType: .string),
               let index = Int(str) {
                oldIndexes.append(index)
            }
        })

        guard let minRow = oldIndexes.first,
              let maxRow = oldIndexes.last,
              minRow == maxRow, // makes sure we only have 1 selected item
              row < minRow || row > maxRow + 1
        else { return false }

        guard let entryToMove = fetchedResultsController.fetchedObjects?[minRow]
        else { return false }
        
        var firstEntry = fetchedResultsController.fetchedObjects?.first
        
        if row > maxRow, let entryToInsertAt = fetchedResultsController.fetchedObjects?[row - 1] {
            if entryToMove.isFirst {
                firstEntry = entryToMove.next
            }
            CDHelper.moveEntry(entryToMove, below: entryToInsertAt)
        }
        else if row < minRow, let entryToInsertAt = fetchedResultsController.fetchedObjects?[row] {
            CDHelper.moveEntry(entryToMove, above: entryToInsertAt)
            if entryToMove.isFirst {
                firstEntry = entryToMove
            }
        }
        
        updateRunningTotals(from: firstEntry)
        
        tableView.reloadData()
        
        return true
    }

}

extension TableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
}

extension TableViewController: NSFetchedResultsControllerDelegate {
    
    

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        _rowDeletes = []
        _rowInserts = []
        _rowUpdates = []
        _rowMoves = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        _rowDeletes = IndexSet(_rowDeletes.sorted(by: { $0 > $1 } ))
//        _rowInserts = IndexSet(_rowInserts.sorted(by: { $0 < $1 } ))
        _performBatchUpdates()
    }
    
    
    private func _performBatchUpdates() {
        tableView.beginUpdates()
        tableView.removeRows(at: _rowDeletes, withAnimation: .slideUp)
        tableView.insertRows(at: _rowInserts, withAnimation: .slideDown)
        _rowMoves.forEach { tableView.moveRow(at: $0.0, to: $0.1) }
        _rowUpdates.forEach { tableView.reloadData(forRowIndexes: [$0], columnIndexes: [0, 1, 2, 3, 4, 5]) }
        tableView.endUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        // print(#function, "type: \(type)", "indexPath: \(indexPath)", "newIndexPath: \(newIndexPath)")
    
        switch type {
        case .insert:
            guard let newIndexPath else { return }
            _rowInserts.insert(newIndexPath.item)
            break
        case .delete:
            guard let newIndexPath else { return }
             _rowDeletes.insert(newIndexPath.item)
            break
        case .update:
            guard let indexPath else { return }
             _rowUpdates.insert(indexPath.item)
            break
        case .move:
            guard let indexPath, let newIndexPath else { return }
            _rowMoves.append((indexPath.item, newIndexPath.item))
            break
        @unknown default:
            break
        }
    }

}

extension TableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            
        guard delegate?.selectedAccount != nil else {
            return nil
        }

        guard let tableColumn,
              let cell = tableView.makeView(withIdentifier: tableColumn.identifier,
                                            owner: self) as? NSTableCellView
        else { return nil }
        
        _configureCell(cell: cell, tableColumn: tableColumn, row: row)
        
        return cell
    }
    
    
    private func _configureCell(cell: NSTableCellView, tableColumn: NSTableColumn, row: Int) {
        // access the fetched AccountEntry at a given row
        guard let entry = fetchedResultsController.fetchedObjects?[row] else {
            return
        }
        // update cell contents by table column ID
        switch tableColumn.identifier {
        case Self.dateColumnID:
             cell.textField?.stringValue = "sort order: \(entry.sortOrder)"
//            cell.textField?.stringValue = Self.dateFormatter.string(from: entry.date)
            break
        case Self.notesColumnID:
            cell.textField?.stringValue = entry.notes
            break
        case Self.debitColumnID:
            cell.textField?.stringValue = Self.currencyFormatter.string(from: entry.debitAmount as NSNumber) ?? ""
            
            if entry.debitAmount.isZero {
                cell.alphaValue = 0.2
            }
            break
        case Self.creditColumnID:
            cell.textField?.stringValue = Self.currencyFormatter.string(from: entry.creditAmount as NSNumber) ?? ""
            if entry.creditAmount.isZero {
                cell.alphaValue = 0.2
            }
            break
        case Self.postedColumnID:
            let customCell = cell as? MyTableCellCheckboxView
            customCell?.linkedObject = entry
            break
        case Self.runningTotalColumnID:
            cell.textField?.stringValue = Self.currencyFormatter.string(from: entry.runningTotal as NSNumber) ?? ""
            cell.textField?.textColor = .systemRed
            break
        default:
            break
        }
    }
    
}

// UI column identifiers + formatters
extension TableViewController {
    static let dateColumnID = NSUserInterfaceItemIdentifier("dateColumnID")
    static let notesColumnID = NSUserInterfaceItemIdentifier("notesColumnID")
    static let debitColumnID = NSUserInterfaceItemIdentifier("debitColumnID")
    static let creditColumnID = NSUserInterfaceItemIdentifier("creditColumnID")
    static let postedColumnID = NSUserInterfaceItemIdentifier("postedColumnID")
    static let runningTotalColumnID = NSUserInterfaceItemIdentifier("runningTotalColumnID")
    
    static let dateFormatter = DateFormatter(dateFormat: "dd/MM")
    static let currencyFormatter = NumberFormatter(currencyCode: "USD")
}
