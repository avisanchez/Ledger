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
    @Environment(ViewController.self)
    private var viewController
    
    //@Binding private var isBlurred: Bool
    
    @FetchRequest
    private var accountEntries: FetchedResults<CDAccountEntry>
    
    @State private var selectedEntryID: CDAccountEntry.ID?
    
    
    init(account: CDAccount?/*, isBlurred: Binding<Bool>*/) {
        //self._isBlurred = isBlurred
        
        let newRequest = CDAccount.fetchRequest()
        newRequest.relationshipKeyPathsForPrefetching = ["entries"]
        
        let request = CDAccountEntry.fetchRequest()
        request.sortDescriptors = [.sortOrder]
        
        if let account {
            request.predicate = NSPredicate(format: "owner == %@", account)
        } else {
            request.predicate = NSPredicate(value: false)
        }
        
        self._accountEntries = FetchRequest(fetchRequest: request, animation: .none)
    }
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 10,
                                                                    maximum: .infinity)),
                                     count: 5)) {
                ForEach(accountEntries, id: \.id) { entry in
                    GridRow {
                        Text(entry.formattedDate)
                        Text(entry.notes)
                        Text(abs(entry.debitAmount), format: .currency(code: "USD"))
                            .opacity(entry.debitAmount.isZero ? 0.1 : 1)
                        Text(abs(entry.creditAmount), format: .currency(code: "USD"))
                            .opacity(entry.creditAmount.isZero ? 0.1 : 1)
                        Image(systemName: entry.posted ? "checkmark" : "square")
                            .bold()
                            .onTapGesture {
                                entry.posted.toggle()
                                viewController.save()
                            }
                    }
                    .padding()
                    .background(.blue)
                    .onTapGesture {
                        print("\(entry.uuid) tapped")
                    }
                }
                .onMove(perform: { indices, newOffset in
                    print("moved!!")
                })
            }
            .contentShape(Rectangle())
        }
        
//        Table(of: CDAccountEntry.self, selection: $selectedEntryID) {
//            TableColumn("Debug") { entry in
//                Text("SELF: \(entry.uuid)")
//                Text("Sort Order: \(entry.sortOrder_)")
//                Text("Prev: \(entry.previous?.uuid)")
//                Text("Next: \(entry.next?.uuid)")
//            }
//            
//            TableColumn("Date", value: \.formattedDate)
//                .width(60)
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
//                        entry.posted.toggle()
//                        viewController.save()
//                    }
//            }
//            .width(10)
//            
//            //            TableColumn("Total") { entry in
//            //                Text(abs(entry.runningTotal), format: .currency(code: "USD"))
//            //                    .foregroundStyle(entry.runningTotal > 0 ? .red : .primary)
//            //                    .opacity(entry.runningTotal.isZero ? 0.1 : 1)
//            //            }
//            //            .width(min: 75)
//            //            .alignment(.trailing)
//        } rows: {
//            ForEach(accountEntries, id: \.id) { entry in
//                TableRow(entry)
//            }
//            
//        }
//        .tableStyle(.inset)
//        .onChange(of: selectedEntryID) { oldValue, newValue in
//            guard oldValue != newValue else { return }
//            
//            let request = CDAccountEntry.fetchRequest()
//            
//            if let uuid = newValue as? NSUUID {
//                request.predicate = NSPredicate(format: "uuid_ == %@", uuid)
//            } else {
//                print("DEBUG: unable to cast")
//                request.predicate = NSPredicate(value: false)
//            }
//            
//            do {
//                viewController.selectedEntry = try viewController.viewContext.fetch(request).first
//                print("Fetch successfull")
//            } catch {
//                print("Failed to fetch selected entry: \(error)")
//            }
//        }
//        .onChange(of: viewController.selectedEntry) { oldValue, newValue in
//            selectedEntryID = newValue?.id
//        }
        
    }
}

