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
}
