//
//  String+helper.swift
//  Ledger
//
//  Created by Avi Sanchez on 6/29/24.
//

import Foundation

extension String {
    var isEmptyOrWhitespace: Bool {
        self.isEmpty || self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var stripped: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
