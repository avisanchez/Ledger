//
//  NSSortDescriptor.swift
//  Ledger
//
//  Created by Avi Sanchez on 7/1/24.
//

import Foundation

extension NSSortDescriptor {
    static let sortOrder = NSSortDescriptor(key: "sortOrder_", ascending: true)
    static let dateOrder = NSSortDescriptor(key: "date_", ascending: true)
}

