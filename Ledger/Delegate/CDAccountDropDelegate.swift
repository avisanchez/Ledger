//
//  AccountDropDelegate.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/29/24.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct CDAccountDropDelegate: DropDelegate {
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return .none
    }
    
    func performDrop(info: DropInfo) -> Bool {
        print("performing drop")
//        let items = info.itemProviders(for: [.propertyList])
//        
//        for item in items {
//            item.loadItem(forTypeIdentifier: UTType.propertyList.identifier) {filePath, error in
//                guard let filePath = filePath as? URL else { 
//                    fatalError("Failed to cast item as URL")
//                }
//                do {
//                } catch {
//                    print("Failed to create account: \(error)")
//                }
//            }
//        }
        return true
    }
    
    
}
