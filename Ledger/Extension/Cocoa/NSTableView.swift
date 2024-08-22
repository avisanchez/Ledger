//
//  NSTableView.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/16/24.
//

import Foundation
import AppKit

extension NSTableView {
    var columnIndexes: IndexSet { .init(integersIn: 0..<self.numberOfColumns) }
    
    func scrollToBottom() {
        guard numberOfRows - 1 >= 0 else { return }
        scrollRowToVisible(numberOfRows - 1)
    }
    
    func scrollToTop() {
        self.animator().scrollRowToVisible(0)
    }
    
    func scrollToSelection() {
        self.animator().scrollRowToVisible(selectedRow)
    }
    
    /*
     Credit to: https://stackoverflow.com/questions/11767557/scroll-an-nstableview-so-that-a-row-is-centered
     */
    func scrollRowToCenter(row: Int, animated: Bool) {
    
        if animated {
            guard let clipView = superview as? NSClipView,
                  let scrollView = clipView.superview as? NSScrollView else {

                    assertionFailure("Unexpected NSTableView view hiearchy")
                    return
            }

            let rowRect = rect(ofRow: row)
            var scrollOrigin = rowRect.origin

            let tableHalfHeight = clipView.frame.height * 0.5
            let rowRectHalfHeight = rowRect.height * 0.5

            scrollOrigin.y = (scrollOrigin.y - tableHalfHeight) + rowRectHalfHeight

            if scrollView.responds(to: #selector(NSScrollView.flashScrollers)) {
                scrollView.flashScrollers()
            }
            clipView.animator().setBoundsOrigin(scrollOrigin)
        } else {
            scrollRowToVisible(row)
        }
    }
}
