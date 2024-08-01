//
//  Constants.swift
//  Ledger
//
//  Created by Avi Sanchez on 7/31/24.
//

import Foundation

final class Constants {
    // This spacing allows for log2(sortOrderSpacing) consecutive insertions before additional entries need to be reordered
    static let sortOrderSpacing: Int = 32
    
    private init() {}
}
