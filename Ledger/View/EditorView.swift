//
//  EditorView.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/28/24.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

struct EditorView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(ViewController.self) var viewController
    
    @ObservedObject var entry: CDAccountEntry
        
    var body: some View {
        HStack {
                        
            BindingTextField("Date",
                             keyPath: \CDAccountEntry.date,
                             format: MyDateFormatStyle(dateFormat: Constants.dateFormat))
                .frame(width: 50)
            
            BindingTextField("Details",
                             keyPath: \CDAccountEntry.notes,
                             format: MyEmptyFormatStyle())
                .frame(width: 250)
            
            BindingTextField("Debit Amount", 
                             keyPath: \CDAccountEntry.debitAmount,
                             format: .currency(code: "USD")) { hasChanges, newValue in
                guard hasChanges else { return }
                viewContext.perform {
                    entry.debitAmount = newValue
                    CDController.updateRunningTotals(from: entry,
                                                     useRoundedTotals: viewController.useRoundedTotals)
                    viewContext.attemptSave()
                }
            }
                .frame(width: 125)
            
            BindingTextField("Credit Amount",
                             keyPath: \CDAccountEntry.creditAmount,
                             format: .currency(code: "USD")) { hasChanges, newValue in
                guard hasChanges else { return }
                viewContext.perform {
                    entry.creditAmount = newValue
                    CDController.updateRunningTotals(from: entry,
                                                     useRoundedTotals: viewController.useRoundedTotals)
                    viewContext.attemptSave()
                }
            }
                .frame(width: 125)
            
            VStack(alignment: .leading) {
                Text("Posted")
                    .font(.caption2)
                    .underline()
                    .bold()
                
                Toggle(isOn: $entry.posted) { }
            }
            .fixedSize()
            
             Spacer()
            
            Text(entry.runningTotal, format: .currency(code: "USD"))
                .fixedSize()
                .font(.title2.weight(.semibold))
                .foregroundStyle(entry.runningTotal < 0 ? .red : .primary)
                .opacity(entry == .placeholder ? 0.2 : 1)
        }
        .environmentObject(entry)
        .disabled(entry == .placeholder)
        .frame(maxWidth: .infinity)
        .padding()
        .background(in: RoundedRectangle(cornerRadius: 10))
        .padding()
    }
}


/*
 A text field that modifies a given NSManagedObject on commit (i.e. on submit or on focus lost).
 */
struct BindingTextField<O: NSManagedObject, T: DefaultInitializable & Equatable, F>: View where F: ParseableFormatStyle, F.FormatInput == T, F.FormatOutput == String {
    
    @EnvironmentObject 
    var object: O
        
    let header: String
    let keyPath: ReferenceWritableKeyPath<O, T>
    let format: F
    let saveChangesOnCommit: Bool
    
    private var _hasChanges: Bool { object[keyPath: keyPath] != _proxyValue }
    
    @State
    private var _proxyValue: T = T()
    
    @FocusState 
    private var _isFocused: Bool
    
    private var _onCommit: ((Bool, T) -> Void)?
    
    init(_ header: String, keyPath: ReferenceWritableKeyPath<O, T>, format: F, saveChangesOnCommit: Bool = true) {
        self.header = header
        self.keyPath = keyPath
        self.format = format
        self.saveChangesOnCommit = saveChangesOnCommit
    }
    
    init(_ header: String, keyPath: ReferenceWritableKeyPath<O, T>, format: F, onCommit: ((_ hasChanges: Bool, _ newValue: T) -> Void)?) {
        self.init(header,
                  keyPath: keyPath,
                  format: format,
                  saveChangesOnCommit: false)
        self._onCommit = onCommit
        
       

    }

    
    var body: some View {
        
        VStack(alignment: .leading) {
            if !header.isEmpty {
                Text(header.capitalized)
                    .font(.caption2)
                    .underline()
                    .bold()
            }
            
            TextField("", value: $_proxyValue, format: format)
                .focused($_isFocused)
        }
        
        // updates the proxy value in the case that the bound field changed outside of this view
        .onChange(of: object[keyPath: keyPath]) { _, newValue in
            _proxyValue = newValue
        }
        // updates the bound value when the focus is lost
        .onChange(of: _isFocused) { _, newValue in
            guard !newValue else { return }
            
            if let _onCommit {
                _onCommit(_hasChanges, _proxyValue)
            } else {
                _updateBoundValue()
            }
        }
        // updates the bound value when the user presses 'enter'
        .onSubmit {
            if let _onCommit {
                _onCommit(_hasChanges, _proxyValue)
            } else {
                _updateBoundValue()
            }
        }
        // initalizes the proxy value since environment variables cannot be accesses in the initalizer
        .onAppear {
            _proxyValue = object[keyPath: keyPath]
        }
    }
    
    private func _updateBoundValue() {
        guard _hasChanges else { return }
        object[keyPath: keyPath] = _proxyValue
        
        guard saveChangesOnCommit, let viewContext = object.managedObjectContext else { return }
        viewContext.perform {
            viewContext.attemptSave()
        }
    }
}

