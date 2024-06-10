//
//  ContentView.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/8/24.
//

import Foundation
import SwiftUI
import SwiftData


struct ContentView: View {
    @State private var viewModel: ViewModel
    @State private var viewModel2: ViewModel2
    
    @State private var isBlurred: Bool
    @State private var searchTerm: String
    @State private var selected: Set<AccountEntry.ID>?
    
    @State private var selectedAccount: Account.ID?
    @State private var selectedEntries: Set<AccountEntry.ID> = []
    
    init(modelContext: ModelContext) {
        self._isBlurred = State(initialValue: false)
        self._searchTerm = State(initialValue: "")
        self._selected = State(initialValue: [])
        self._viewModel = State(initialValue: ViewModel(context: modelContext))
        self._viewModel2 = State(initialValue: ViewModel2(modelContext: modelContext))
    }
    
    var body: some View {
        
        NavigationSplitView( 
            sidebar: {
                SidebarView()
        }, detail: {
            VStack {
                
//                ScrollViewReader { proxy in
                    AccountTableView(selectedAccount: viewModel2.selectedAccount,
                                     isBlurred: $isBlurred)
                        .conditionalBlurStyle(isBlurred)
                        .disabled(isBlurred)
////                        
////                        .onAppear {
////                            guard let lastEntry = viewModel.accountEntries.last else { return }
////                            proxy.scrollTo(lastEntry.id)
////                        }
////                        .onSubmit(of: .search) {
////                            guard let id = viewModel.searchFor(searchTerm) else { return }
////                            
////                            viewModel.selected = [id]
////                            proxy.scrollTo(id, anchor: .center)
////                        }
//                }
                                
//                EditorView(selected: $selected)
//                    .conditionalBlurStyle(isBlurred)
//                    .allowsHitTesting(!isBlurred)
            }
        })
        .environment(viewModel)
        .environment(viewModel2)
        .searchable(text: $searchTerm, prompt: "Search notes")
        //.navigationTitle("\(viewModel.accountName)")
        //.onDrop(of: AccountDropDelegate.allowedTypes, delegate: AccountDropDelegate())
        .toolbar {
            
            Button {
                
            } label: {
                Image(systemName: "square.and.arrow.down")
            }

            
            Button {
                withAnimation { isBlurred.toggle() }
            } label: {
                Image(systemName: isBlurred ? "eye.slash" : "eye")
            }
            
            Button {
                print("adding entry!")
                viewModel2.createEntry()
            } label: {
                Image(systemName: "plus")
            }
            
            //Toggle("RT", isOn: $viewModel.useRoundedTotals)
        }
        .onChange(of: viewModel2.selectedAccount) { oldValue, newValue in
            print("Selected account: \(newValue?.name)")
        }
    }
    
}

//#Preview {
//    ContentView(modelContext: <#T##ModelContext#>)
//}
