//
//  EditorView.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/28/24.
//

import Foundation
import SwiftUI
import SwiftData

struct EditorView: View {
    
    @Binding var entry: CDAccountEntry?
    @State private var proxyEntry: ProxyAccountEntry = ProxyAccountEntry()
    
    init(_ entry: Binding<CDAccountEntry?>) {
        self._entry = entry
    }
            
    var body: some View {
        
        HStack {
            VStack(alignment: .leading) {
                Text("Date")
                    .editorSectionHeaderStyle()
                TextField("Enter Date", value: $proxyEntry.date,
                          formatter: DateFormatter(dateFormat: "MM/dd"))
            }


            VStack(alignment: .leading) {
                Text("Details")
                    .editorSectionHeaderStyle()
                TextField("Enter Details", text: $proxyEntry.notes)
            }

            VStack(alignment: .leading) {
                Text("Debit Amount")
                    .editorSectionHeaderStyle()
                TextField("Enter Debit Amount", value: $proxyEntry.debitAmount,
                          formatter: NumberFormatter(numberStyle: .decimal))
            }

            VStack(alignment: .leading) {
                Text("Credit Amount")
                    .editorSectionHeaderStyle()
                
                TextField("Enter Credit Amount", value: $proxyEntry.creditAmount,
                          formatter: NumberFormatter(numberStyle: .decimal))
            }

        }
        .frame(maxWidth: .infinity)
        .textFieldStyle(.plain)
        .padding()
        .background(in: RoundedRectangle(cornerRadius: 10))
        .padding()
        .onChange(of: entry) { oldValue, newValue in
            print("DEBUG: subview entry changed")
        }
    }
    
    private struct ProxyAccountEntry {
        var date: Date
        var notes: String
        var debitAmount: Double
        var creditAmount: Double
        var posted: Bool
        
        init(date: Date = Date(), notes: String = "", debitAmount: Double = 0, creditAmount: Double = 0, posted: Bool = false) {
            self.date = date
            self.notes = notes
            self.debitAmount = debitAmount
            self.creditAmount = creditAmount
            self.posted = posted
        }
    }
}
