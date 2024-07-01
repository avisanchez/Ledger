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
    @Environment(ViewController.self)
    private var viewController
        
    @State private var editableDate: Date
    @State private var editableNotes: String
    @State private var editableCreditAmount: Double
    @State private var editableDebitAmount: Double
    
    init(_ entry: CDAccountEntry?) {
        self._editableDate = State(initialValue: entry?.date ?? Date())
        self._editableNotes = State(initialValue: entry?.notes ?? "")
        self._editableDebitAmount = State(initialValue: entry?.debitAmount ?? 0.0)
        self._editableCreditAmount = State(initialValue: entry?.creditAmount ?? 0.0)
        
        print("\(editableDate), \(editableNotes), \(editableDebitAmount), \(editableCreditAmount)")
    }
            
    var body: some View {
        let _ = print("\(editableDate), \(editableNotes), \(editableDebitAmount), \(editableCreditAmount)")
        
        HStack {
            VStack(alignment: .leading) {
                Text("Date")
                    .editorSectionHeaderStyle()
                TextField("Enter Date", value: $editableDate,
                          formatter: DateFormatter(dateFormat: "MM/dd"))
            }


            VStack(alignment: .leading) {
                Text("Details")
                    .editorSectionHeaderStyle()
                TextField("Enter Details", text: $editableNotes)
            }

            VStack(alignment: .leading) {
                Text("Debit Amount")
                    .editorSectionHeaderStyle()
                TextField("Enter Debit Amount", value: $editableDebitAmount,
                          formatter: NumberFormatter(numberStyle: .decimal))
            }

            VStack(alignment: .leading) {
                Text("Credit Amount")
                    .editorSectionHeaderStyle()

                TextField("Enter Credit Amount", value: $editableCreditAmount,
                          formatter: NumberFormatter(numberStyle: .decimal))
            }


            VStack(spacing: 10) {
                Button {
                } label: {
                    
                    Image(systemName: "arrow.up")
                }


                Button {
                    
                } label: {
                    Image(systemName: "arrow.down")
                }

            }
            .buttonStyle(.plain)
            .bold()

        }
        .frame(maxWidth: .infinity)
        .textFieldStyle(.plain)
        .padding()
        .background(in: RoundedRectangle(cornerRadius: 10))
        .padding()
        .onChange(of: viewController.selectedEntry) { oldValue, newValue in
            // save old values
            
            // update new values
        }
        
    }
}
