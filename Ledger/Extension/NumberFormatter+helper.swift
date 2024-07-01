//
//  NumberFormatter.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/28/24.
//

import Foundation

extension NumberFormatter {
    convenience init(numberStyle: Style) {
        self.init()
        self.numberStyle = numberStyle
    }
}
