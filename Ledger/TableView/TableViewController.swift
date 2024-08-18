import Foundation
import AppKit
import SwiftUI

class TableViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBAction func didFinishEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let col = tableView.column(for: sender)
        print("DEBUG \(#function): (\(row),\(col)) finished editing!")
        
        let tableColumnId = tableView.tableColumns[col].identifier
        
        if tableColumnId == Self.debitColumnID || 
           tableColumnId == Self.creditColumnID {
            updateRunningTotals(from: FRC.shared.fetchedObjects?[row])
        }
        
        PersistenceController.shared.viewContext.attemptSave()
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let entry = FRC.shared.fetchedObjects?[row]
        else { return nil }
        
        return entry
    }
    
    
    // To sync with SwiftUI
    weak var delegate: TableViewControllerDelegate?
    
    private var _draggedRow: Int? {
        didSet {
            
            var rowIndexesToReload = IndexSet()
            
            if let _draggedRow {
                rowIndexesToReload.insert(_draggedRow)
            }
            
            if let oldValue {
                rowIndexesToReload.insert(oldValue)
            }
            
            tableView.reloadData(forRowIndexes: rowIndexesToReload,
                                 columnIndexes: tableView.columnIndexes)
        }
    }
    
    enum JumpDestination {
        case top
        case bottom
        case selection
        case none
    }
    
    func jump(to destination: JumpDestination) {
        delegate?.jumpDestination = .none
        
        var rowIndex: Int
        
        switch destination {
        case .top:
            rowIndex = 0
            break
        case .bottom:
            guard let fetchedObjects = FRC.shared.fetchedObjects else { return }
            rowIndex = fetchedObjects.count - 1
            break
        case .selection:
            rowIndex = tableView.selectedRow
            break
        case .none:
            return
        }
       
        tableView.scrollRowToVisible(rowIndex)
    }
    
    
    
    func updateRunningTotals(from start: CDAccountEntry? = nil, to end: CDAccountEntry? = nil) {
        guard let delegate else { return }
        let start = (start == nil) ? FRC.shared.firstObject : start
        CDController.updateRunningTotals(from: start, to: end, useRoundedTotals: delegate.useRoundedTotals)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerForDraggedTypes([.string])
        FRC.shared.tableView = tableView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let delegate else { return 30 }
        
        switch delegate.scale {
        case .xsmall:
            return 20
        case .small:
            return 25
        case .regular:
            return 30
        case .large:
            return 35
        case .xlarge:
            return 40
        case .xxlarge:
            return 45
        case .xxxlarge:
            return 50
        }
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let delegate else { return }
        
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0 else {
            delegate.didSelectRow(nil)
            return
        }
        delegate.didSelectRow(FRC.shared.fetchedObjects?[selectedRow])
    }
    
    func updateSelection() {
        guard let selectedEntry = delegate?.selectedEntry,
        let row = FRC.shared.indexPath(forObject: selectedEntry)?.item
        else { return }
        
        tableView.selectRowIndexes([row], byExtendingSelection: false)
    }

    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        
        if edge == .trailing {
            let deleteRowAction = NSTableViewRowAction(style: .destructive, title: "delete") { _, index in
                guard let delegate = self.delegate,
                      let entryToDelete = FRC.shared.fetchedObjects?[index]
                else { return }

                PersistenceController.shared.viewContext.perform {
                    CDController.delete(entryToDelete, useRoundedTotals: delegate.useRoundedTotals) { success, newSelf in
                        guard success, delegate.selectedEntry == nil else { return }
                        delegate.didSelectRow(newSelf)
                    }
                }
            }
            let trashImage = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
            deleteRowAction.image = trashImage
            
            let editRowAction = NSTableViewRowAction(style: .regular, title: "edit") { _, index in
                tableView.rowActionsVisible.toggle()
                return
            }
            let pencilImage = NSImage(systemSymbolName: "pencil", accessibilityDescription: nil)
            editRowAction.image = pencilImage
            editRowAction.backgroundColor = .systemYellow
            
            let archiveRowAction = NSTableViewRowAction(style: .regular, title: "archive") { _, index in
                tableView.rowActionsVisible.toggle()
            }
            let archiveImage = NSImage(systemSymbolName: "archivebox", accessibilityDescription: nil)
            archiveRowAction.image = archiveImage
            archiveRowAction.backgroundColor = .systemPurple
            
            return [editRowAction, archiveRowAction, deleteRowAction]
        }
        
        return []
    }

}


extension TableViewController: NSTableViewDataSource {
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard delegate?.selectedAccount != nil,
              let fetchedObjects = FRC.shared.fetchedObjects
        else { return 0 }

        return fetchedObjects.count
    }
    
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let pasteboard = NSPasteboardItem()
        pasteboard.setString("\(row)", forType: .string)
        return pasteboard
    }

    
    func tableView(_ tableView: NSTableView, validateDrop info: any NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        return .move
    }
    
    
    /*
     This method attempts to provide a custom drag image when a user drags a table view row. The current implementation only works for single row dragging (i.e. single selection).
     */
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        tableView.draggingDestinationFeedbackStyle = .regular
        session.animatesToStartingPositionsOnCancelOrFail = true
        
        var zeroPoint = NSZeroPoint
        let dragImageNoBackground = tableView.dragImageForRows(with: rowIndexes,
                                                   tableColumns: tableView.tableColumns,
                                                   event: NSEvent(),
                                                   offset: &zeroPoint)
        let rowView = tableView.rowView(atRow: rowIndexes.last!, makeIfNecessary: true)

        let dragImageWithBackground = NSImage(size: dragImageNoBackground.size,
                                              flipped: false) { rect in
            NSColor.controlAccentColor.setFill()
            let roundedRect = NSBezierPath(roundedRect: rect,
                                           xRadius: 10,
                                           yRadius: 10)
            roundedRect.fill()
            dragImageNoBackground.draw(in: rect)
            return true
        }
        
        session.enumerateDraggingItems(options: .concurrent,
                                       for: rowView,
                                       classes: [NSPasteboardItem.self],
                                       searchOptions: [:]) { item, _, _ in
            let newFrame = NSRect(x: -screenPoint.x,
                                  y: item.draggingFrame.minY,
                                  width: dragImageWithBackground.size.width,
                                  height: dragImageWithBackground.size.height)
            
            item.setDraggingFrame(newFrame, contents: dragImageWithBackground)
        }
        
        self._draggedRow = rowIndexes.first
    }
    
    
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        self._draggedRow = nil
    }
    
    /*
     This implementation assumes the table only allows single selection
     */
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {

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

        guard let entryToMove = FRC.shared.fetchedObjects?[minRow]
        else { return false }
        
        /*
         The first entry may change during row reordering and the fetched results controller will not upate until after this methd returns. We must keep a local version of the first entry and update it locally so running totals can be correctly recalculated from the true first entry.
         */
        var firstEntry = FRC.shared.fetchedObjects?.first
        
        if row > maxRow, let entryToInsertAt = FRC.shared.fetchedObjects?[row - 1] {
            if entryToMove.isFirst {
                firstEntry = entryToMove.next
            }
            CDController.moveEntry(entryToMove, below: entryToInsertAt)
        }
        else if row < minRow, let entryToInsertAt = FRC.shared.fetchedObjects?[row] {
            CDController.moveEntry(entryToMove, above: entryToInsertAt)
            if entryToMove.isFirst {
                firstEntry = entryToMove
            }
        }
        
        if let delegate {
            CDController.updateRunningTotals(from: firstEntry, useRoundedTotals: delegate.useRoundedTotals)
        }
                
        return true
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
        
        
        if row == self._draggedRow {
            cell.alphaValue = 0.2
        } else {
            _configureCell(cell: cell, tableColumn: tableColumn, row: row)
        }
        
        return cell
    }

    private func _configureCell(cell: NSTableCellView, tableColumn: NSTableColumn, row: Int) {
        // access the fetched AccountEntry at a given row
        guard let entry = FRC.shared.fetchedObjects?[row] else {
            return
        }
        
        // update cell contents by table column ID
        switch tableColumn.identifier {
        case Self.dateColumnID:
            break
        case Self.notesColumnID:
            break
        case Self.debitColumnID:
            if entry.debitAmount.isZero {
                cell.alphaValue = 0.2
            }
            break
        case Self.creditColumnID:
            if entry.creditAmount.isZero {
                cell.alphaValue = 0.2
            }
            break
        case Self.postedColumnID:
            let customCell = cell as? MyTableCellCheckboxView
            customCell?.linkedObject = entry
            break
        case Self.runningTotalColumnID:
            if entry.runningTotal.isZero {
                cell.alphaValue = 0.2
            }
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
    
    static let textFieldErrorString = "---"
    
}
