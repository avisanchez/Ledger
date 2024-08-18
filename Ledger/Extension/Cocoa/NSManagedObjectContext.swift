//
//  NSManagedObjectContext+helper.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/4/24.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    @discardableResult
    func attemptSave() -> Bool {
        
        do {
            try self.save()
            return true
        } catch {
            print("Failed to save context with error: \(error)")
        }
        return false
        
    }
}
