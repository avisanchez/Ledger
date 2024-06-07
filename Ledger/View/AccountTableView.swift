//
//  AccountTableView.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/27/24.
//

import Foundation
import SwiftUI
import SwiftData


struct AccountTableView: View {
    
    @Environment(ViewModel.self)
    private var viewModel
        
    @Binding private var selected: Set<AccountEntry.ID>
    @Binding private var isBlurred: Bool
    
    init(selected: Binding<Set<AccountEntry.ID>>, isBlurred: Binding<Bool>) {
        self._selected = selected
        self._isBlurred = isBlurred
    }

    var body: some View {
        Table(viewModel.accountEntries, selection: $selected) {
            
            TableColumn("Date") { entry in
                Text(DateFormatter.format(entry.date, using: "dd/MM"))
            }
            .width(60)
            
            TableColumn("Details", value: \.notes)
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
                        //viewModel.togglePostedStatus(for: entry)
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
