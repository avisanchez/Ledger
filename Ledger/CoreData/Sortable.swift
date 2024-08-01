//
//  CustomOrderedType.swift
//  Ledger
//
//  Created by Avi Sanchez on 6/21/24.
//

import Foundation

protocol Sortable {
    var previous: Self? {
        get
        set
    }
    var next: Self? {
        get
        set
    }
    var sortOrder: Int {
        get
        set
    }
}
