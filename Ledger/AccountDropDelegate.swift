//
//  AccountDropDelegate.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/29/24.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct AccountDropDelegate: DropDelegate {
    
    static let allowedTypes: [UTType] = [.propertyList, .json]
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: AccountDropDelegate.allowedTypes)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let items = info.itemProviders(for: [.propertyList])
        
        for item in items {
            item.loadItem(forTypeIdentifier: UTType.propertyList.identifier) {filePath, error in
                guard let filePath = filePath as? URL else { 
                    fatalError("Failed to cast item as URL")
                }
                do {
                    //let entries = try loadEntries(from: filePath)
                } catch {
                    print("Failed to create account: \(error)")
                }
            }
        }
        return true
    }
    
    
}
