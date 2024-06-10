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
    
    @Environment(ViewModel2.self)
    private var viewModel2
    
    //@Query private var account: [Account]
    @Query private var accountEntries: [AccountEntry]
    
    @Binding private var isBlurred: Bool
    
    init(selectedAccount: Account?, isBlurred: Binding<Bool>) {
        self._isBlurred = isBlurred

        var descriptor = FetchDescriptor<AccountEntry>()
        if let selectedAccount {
            descriptor.predicate = #Predicate<AccountEntry> { item in
                if let owner = item.owner {
                    return owner.id == selectedAccount.id
                } else {
                    return false
                }
            }
        } else {
            descriptor.predicate = #Predicate<AccountEntry> { _ in false }
        }
        _accountEntries = Query(descriptor)
    }
    
    var body: some View {
        Table(of: AccountEntry.self, selection: Bindable(viewModel2).selectedEntries) {
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
        } rows: {
            ForEach(accountEntries, id: \.id) { entry in
                TableRow(entry)
                    // TODO: implement draggable
            }
        }
        .tableStyle(.inset)
        

//        Table(accountEntries, selection: Bindable(viewModel2).selectedEntries) {
//            TableColumn("Date") { entry in
//                Text(DateFormatter.format(entry.date, using: "dd/MM"))
//            }
//            .width(60)
//            
//            TableColumn("Details", value: \.notes)
//                .width(min: 100)
//            
//            TableColumn("Debit") { entry in
//                Text(abs(entry.debitAmount), format: .currency(code: "USD"))
//                    .opacity(entry.debitAmount.isZero ? 0.1 : 1)
//            }
//            .width(min: 75)
//            
//            TableColumn("Credit") { entry in
//                Text(abs(entry.creditAmount), format: .currency(code: "USD"))
//                    .opacity(entry.creditAmount.isZero ? 0.1 : 1)
//            }
//            .width(min: 75)
//            
//            TableColumn("P") { entry in
//                Image(systemName: entry.posted ? "checkmark" : "square")
//                    .bold()
//                    .onTapGesture {
//                        //viewModel.togglePostedStatus(for: entry)
//                    }
//            }
//            .width(10)
//            
//            TableColumn("Total") { entry in
//                Text(abs(entry.runningTotal), format: .currency(code: "USD"))
//                    .foregroundStyle(entry.runningTotal > 0 ? .red : .primary)
//                    .opacity(entry.runningTotal.isZero ? 0.1 : 1)
//            }
//            .width(min: 75)
//            .alignment(.trailing)
//        }
//        .tableStyle(.inset)
        
        
    }
}
