//
//  ContentView.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/8/24.
//

import Foundation
import SwiftUI


struct ContentView: View {

    @State private var viewModel = ViewModel()
    @State private var isBlurred: Bool
    @State private var searchTerm: String
    
    init() {
        self._isBlurred = State(initialValue: false)
        self._searchTerm = State(initialValue: "")
    }
    
    var body: some View {
        
        NavigationSplitView( 
            sidebar: {
                

        }, detail: {
            VSplitView {
                
                ScrollViewReader { proxy in
                    AccountTableView()
                        .conditionalBlurStyle(isBlurred)
                        .disabled(isBlurred)
                        
                        .onAppear {
                            guard let lastEntry = viewModel.accountEntries.last else { return }
                            proxy.scrollTo(lastEntry.id)
                        }
                        .onSubmit(of: .search) {
                            guard let id = viewModel.searchFor(searchTerm) else { return }
                            
                            viewModel.selected = [id]
                            proxy.scrollTo(id, anchor: .center)
                        }
                }
                
                EditorView()
                    .conditionalBlurStyle(isBlurred)
                    .allowsHitTesting(!isBlurred)
            }
        })
        .environment(viewModel)
        .searchable(text: $searchTerm, prompt: "Search notes")
        .navigationTitle("\(viewModel.accountName)")
        .fontDesign(.monospaced)
        .onDrop(of: AccountDropDelegate.allowedTypes, delegate: AccountDropDelegate())
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
            
//            Button {
//                guard let entry = viewModel.getFirstSelectedEntry(from: selected) else { return }
//                viewModel.insert(AccountEntry(), at: entry.id)
//            } label: {
//                Image(systemName: "plus")
//            }
            
            Toggle("RT", isOn: $viewModel.useRoundedTotals)
        }
    }
    
}

#Preview {
    ContentView()
}
