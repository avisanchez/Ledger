//
//  FetchDescriptor.swift
//  Ledger
//
//  Created by Avi Sanchez on 6/6/24.
//

import Foundation
import SwiftData

extension FetchDescriptor {
    
    init(predicate: Predicate<T>? = nil,
         propertiesToFetch: [PartialKeyPath<T>]? = nil,
         relationshipKeyPathsForPrefetching: [PartialKeyPath<T>]? = nil,
         sortBy: [SortDescriptor<T>]? = nil) {
        self.init()
        
        if let predicate {
            self.predicate = predicate
        }
        
        if let sortBy {
            self.sortBy = sortBy
        }
        
        if let relationshipKeyPathsForPrefetching {
            self.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
        }
        
        if let propertiesToFetch {
            self.propertiesToFetch = propertiesToFetch
        }
    }
}
