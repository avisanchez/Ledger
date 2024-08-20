//
//  ViewController.swift
//  Ledger
//
//  Created by Avi Sanchez on 6/11/24.
//

import Foundation
import CoreData
import Observation
import SwiftUI

enum TableScale: CaseIterable, Identifiable {
    var id: UUID { UUID() } 
    
    case xsmall
    case small
    case regular
    case large
    case xlarge
    case xxlarge
    case xxxlarge
}

@Observable
class ViewController {
    
    var selectedAccount: CDAccount? = nil
    
    var selectedEntry: CDAccountEntry? = nil
        
    var useRoundedTotals: Bool = false
        
    var fileImporterIsPresented: Bool = false
    
    var tableScale: TableScale = .regular
}
