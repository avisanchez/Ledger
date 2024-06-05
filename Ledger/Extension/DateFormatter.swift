//
//  DateFormatter.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/27/24.
//

import Foundation

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
    
    static func format(_ date: Date, using dateFormat: String) -> String {
        return DateFormatter(dateFormat: dateFormat).string(from: date)
    }
}
