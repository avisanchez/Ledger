//
//  AccountTableView.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/27/24.
//

import SwiftUI
import Foundation

struct AccountTableView: View {
    
    @Environment(ViewModel.self) var viewModel: ViewModel
        
    private let dateFormat = "dd/MM"

    var body: some View {
        @Bindable var viewModel = viewModel
        
        Table(viewModel.accountEntries, selection: $viewModel.selected) {
            TableColumn("Date") { entry in
                Text(DateFormatter.format(entry.date, using: dateFormat))
            }
            .width(60)
            
            TableColumn("Details") { entry in
                Text(entry.notes)
            }
            .width(min: 100)
            
            TableColumn("Debit") { entry in
                Text(abs(entry.debitAmount), format: .currency(code: "USD"))
                    .opacity(entry.debitAmount.isZero ? 0.1 : 1)
            }
            .width(min: 75)
            
            TableColumn("Credit") { entry in
                Text(abs(entry.creditAmount), format: .currency(code: "USD"))
                    .opacity(entry.creditAmount.isZero ? 0.1 : 1)
            }
            .width(min: 75)
            
            TableColumn("P") { entry in
                Image(systemName: entry.posted ? "checkmark" : "square")
                    .bold()
                    .onTapGesture {
                        viewModel.togglePostedStatus(for: entry)
                    }
            }
            .width(10)
            
            TableColumn("Total") { entry in
                Text(abs(entry.runningTotal), format: .currency(code: "USD"))
                    .foregroundStyle(entry.runningTotal > 0 ? .red : .primary)
                    .opacity(entry.runningTotal.isZero ? 0.1 : 1)
            }
            .width(min: 75)
            .alignment(.trailing)
        }
        .tableStyle(.inset)
        
    }
}
