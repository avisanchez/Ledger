import Foundation
import AppKit
import SwiftUI


class TableViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!

    @IBAction func nsButtonUpdate(_ sender: NSButton) {
        delegate?.viewContext.attemptSave()
    }
    
    @IBAction func nsTextFieldUpdate(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let col = tableView.column(for: sender)
//        print("DEBUG \(#function): (\(row),\(col)) finished editing!")
//        print("text field string value: \(sender.stringValue)")
//        print("binding info: \(sender.infoForBinding(.valuePath))")
        
        let tableColumnId = tableView.tableColumns[col].identifier
        
        if tableColumnId == Self.debitColumnID ||
           tableColumnId == Self.creditColumnID {
            let modifiedObject = FRC.main.fetchedObjects?[row]
            _updateRunningTotals(from: modifiedObject)
        }
        delegate?.viewContext.attemptSave()
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let entry = FRC.main.fetchedObjects?[row]
        else { return nil }
        
        return entry
    }
    
    override func keyDown(with event: NSEvent) {
        if event.specialKey == .delete {
            guard let viewContext = delegate?.viewContext,
                  let selectedEntry = delegate?.selectedEntry,
                  let useRoundedTotals = delegate?.useRoundedTotals
            else { return }
            
            viewContext.perform {
                CDController.delete(selectedEntry, useRoundedTotals: useRoundedTotals) { success, newSelf in
                    guard success else { return }
                    self.delegate?.didSelectRow(newSelf)
                }
            }
        } else if event.keyCode == 49 && event.modifierFlags.contains([.shift, .command]) {
            tableView.scrollRowToCenter(row: tableView.selectedRow, animated: true)
        }
        
        
        
        
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
    
    
    func _updateRunningTotals(from start: CDAccountEntry? = nil, to end: CDAccountEntry? = nil) {
        guard let delegate else { return }
        let start = (start == nil) ? FRC.main.firstObject : start
        CDController.updateRunningTotals(from: start, to: end, useRoundedTotals: delegate.useRoundedTotals)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerForDraggedTypes([.string])
        FRC.main.tableView = tableView
    }
    
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
//        guard let delegate else { return 30 }
//        
//        switch delegate.tableScale {
//        case .xsmall:
//            return 20
//        case .small:
//            return 25
//        case .regular:
//            return 30
//        case .large:
//            return 35
//        case .xlarge:
//            return 40
//        case .xxlarge:
//            return 45
//        case .xxxlarge:
//            return 50
//        }
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let delegate else { return }
        
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0 else {
            delegate.didSelectRow(nil)
            return
        }
        delegate.didSelectRow(FRC.main.fetchedObjects?[selectedRow])
    }
    
    func updateSelection() {
        guard let selectedEntry = delegate?.selectedEntry,
        let row = FRC.main.indexPath(forObject: selectedEntry)?.item
        else { return }
        
        tableView.selectRowIndexes([row], byExtendingSelection: false)
        tableView.scrollRowToVisible(row)
    }

    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        guard edge == .trailing else { return [] }
        
        if let delegate, delegate.isSearching {
            return [jumpToEntryAction, deleteRowAction]
        }
        
        return [archiveRowAction, deleteRowAction]
    }

}


extension TableViewController: NSTableViewDataSource {
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard delegate?.selectedAccount != nil,
              let fetchedObjects = FRC.main.fetchedObjects
        else { return 0 }

        return fetchedObjects.count
    }
    
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let delegate, !delegate.isSearching else { return nil }
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

        guard let entryToMove = FRC.main.fetchedObjects?[minRow]
        else { return false }
        
        if row > maxRow, let entryToInsertAt = FRC.main.fetchedObjects?[row - 1] {
            let firstEntryToUpdate = entryToMove.next
            CDController.moveEntry(entryToMove, below: entryToInsertAt)
            _updateRunningTotals(from: firstEntryToUpdate, to: entryToMove)
        }
        else if row < minRow, let entryToInsertAt = FRC.main.fetchedObjects?[row] {
            let lastEntryToUpdate = entryToMove.previous
            CDController.moveEntry(entryToMove, above: entryToInsertAt)
            _updateRunningTotals(from: entryToMove, to: lastEntryToUpdate)
        }
                        
        return true
    }
}

extension TableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard delegate?.selectedAccount != nil,
              let tableColumn,
              let cell = tableView.makeView(withIdentifier: tableColumn.identifier,
                                            owner: self) as? NSTableCellView
        else { return nil }
        
        _configureCell(cell: cell, tableColumn: tableColumn, row: row)
        
        if row == self._draggedRow {
            cell.alphaValue = 0.2
        }
            
        

        return cell
    }

    private func _configureCell(cell: NSTableCellView, tableColumn: NSTableColumn, row: Int) {
        // access the fetched AccountEntry at a given row
        guard let entry = FRC.main.fetchedObjects?[row] else {
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
//            let customCell = cell as? MyTableCellCheckboxView
//            customCell?.linkedObject = entry
            break
        case Self.runningTotalColumnID:
            if entry.runningTotal < 0 {
//                (cell as? MyTableCellTextFieldView)?.textField?.textColor = .systemRed
                cell.textField?.textColor = .systemRed
            } else {
                cell.textField?.textColor = .controlTextColor
            }
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

// Row Actions
extension TableViewController {
    var deleteRowAction: NSTableViewRowAction {
            let deleteRowAction = NSTableViewRowAction(style: .destructive, title: "delete") { _, index in
                guard let delegate = self.delegate,
                      let entryToDelete = FRC.main.fetchedObjects?[index]
                else { return }
        
                delegate.viewContext.perform {
                    CDController.delete(entryToDelete, useRoundedTotals: delegate.useRoundedTotals) { success, newSelf in
                        guard success, delegate.selectedEntry == entryToDelete else { return }
                        delegate.didSelectRow(newSelf)
                    }
                }
            }
            let trashImage = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
            deleteRowAction.image = trashImage
        
        return deleteRowAction
    }
    
    var archiveRowAction: NSTableViewRowAction {
        let archiveRowAction = NSTableViewRowAction(style: .regular, title: "archive") { _, index in
            self.tableView.rowActionsVisible.toggle()
        }
        let archiveImage = NSImage(systemSymbolName: "archivebox", accessibilityDescription: nil)
        archiveRowAction.image = archiveImage
        archiveRowAction.backgroundColor = .systemPurple
        
        return archiveRowAction
    }
    
    var jumpToEntryAction: NSTableViewRowAction {
        let jumpToEntryAction = NSTableViewRowAction(style: .regular, title: "goto") { _, index in
            self.tableView.rowActionsVisible.toggle()
            guard let delegate = self.delegate else { return }
            let entryToFocus = FRC.main.fetchedObjects?[index]
            delegate.dismissSearch()
            delegate.didSelectRow(entryToFocus)
            self.tableView.scrollRowToVisible(index)
        }
        let jumpToImage = NSImage(systemSymbolName: "line.diagonal.arrow", accessibilityDescription: nil)
        jumpToEntryAction.image = jumpToImage
        jumpToEntryAction.backgroundColor = .systemFill
        
        return jumpToEntryAction
    }
}
