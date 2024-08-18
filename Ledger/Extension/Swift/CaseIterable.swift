//
//  CaseIterable.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/17/24.
//

import Foundation

extension CaseIterable where Self: Equatable {
    func advanced(by n: Int) -> Self {
        let all = Array(Self.allCases)
        let idx = (all.firstIndex(of: self)! + n) % all.count
        
        if idx >= 0 {
            return all[idx]
        } else {
            return all[all.count + idx]
        }
    }
}
