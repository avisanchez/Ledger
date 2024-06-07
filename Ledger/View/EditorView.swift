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
    
    @Environment(ViewModel.self)
    private var viewModel
    
    @Environment(\.modelContext) 
    private var modelContext
    
    
    @Binding private var selected: Set<AccountEntry.ID>
    
    init(selected: Binding<Set<AccountEntry.ID>>) {
        self._selected = selected
                
//        let request = FetchDescriptor<AccountEntry>(predicate: #Predicate { entry in
//            entry.id == UUID()
//        })
//        let request = FetchRequest(entity: AccountEntry.self, predicate: #Predicate<AccountEntry.self> {
//            $0.id == selectedEntry.id
//        })
//        
//        modelContext.fetch(request)
    }
    
    var body: some View {
        
        Text("Editor View Goes Here")
            .padding()
//        if (viewModel.selected.count <= 1) {
//            SingleSelectView()
//        }
//        else {
//            MultiSelectView()
//        }
    }
}

extension EditorView {
    private struct MultiSelectView: View {
        var body: some View {
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 71)
                        .padding()
                        .scaleEffect(CGFloat(1.0 - 0.02 * Double(i)))
                        .opacity(CGFloat(1 - 0.1 * Double(i)))
                        .zIndex(-Double(i))
                        .shadow(color: .primary.opacity(0.2), radius: 2)
                        .offset(y: Double(5 * i))
                        .foregroundStyle(.white)
                }
                
                
            }
        }
    }
    
    private struct SingleSelectView: View {
        @Environment(ViewModel.self) var viewModel: ViewModel
        
        private let dateFormat = "dd/MM/yyyy"
        
        var body: some View {
            @Bindable var viewModel = viewModel
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Date")
                        .editorSectionHeaderStyle()
                    TextField("Enter Date", value: $viewModel.editableEntry.date,
                              formatter: DateFormatter(dateFormat: dateFormat))
                }


                VStack(alignment: .leading) {
                    Text("Details")
                        .editorSectionHeaderStyle()
                    TextField("Enter Details", text: $viewModel.editableEntry.notes)
                }

                VStack(alignment: .leading) {
                    Text("Debit Amount")
                        .editorSectionHeaderStyle()
                    TextField("Enter Debit Amount", value: $viewModel.editableEntry.debitAmount,
                              formatter: NumberFormatter(numberStyle: .decimal))
                }

                VStack(alignment: .leading) {
                    Text("Credit Amount")
                        .editorSectionHeaderStyle()

                    TextField("Enter Credit Amount", value: $viewModel.editableEntry.creditAmount,
                              formatter: NumberFormatter(numberStyle: .decimal))
                }


                VStack(spacing: 10) {
                    Button {
                        viewModel.swapSelectedEntries(direction: .up)
                    } label: {
                        Image(systemName: "arrow.up")
                    }


                    Button {
                        viewModel.swapSelectedEntries(direction: .down)
                    } label: {
                        Image(systemName: "arrow.down")
                    }

                }
                .buttonStyle(.plain)
                .bold()

            }
            .textFieldStyle(.plain)
            .padding()
            .background(in: RoundedRectangle(cornerRadius: 10))
            .padding()
            .onSubmit(of: .text) {
                guard let entry = viewModel.firstSelectedEntry() else { return }
                viewModel.replace(entry, with: viewModel.editableEntry)
            }
        }
    }
}
