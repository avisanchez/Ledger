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
    @Environment(ViewController.self)
    private var viewController
    
    @State private var isBlurred: Bool = false
    @State private var searchTerm: String = ""
    @State private var scrolledID: CDAccountEntry.ID?
    @State private var useRoundedTotals: Bool = false
    
    var body: some View {
        
        NavigationSplitView {
            SidebarView()
        } detail: {
            
            VStack {
                ScrollViewReader { proxy in
                    ZStack(alignment: .bottomTrailing) {
                        
                        AccountTableView(account: viewController.selectedAccount)
                            .onChange(of: viewController.selectedEntry) { oldValue, newValue in
                                guard let newValue else { return }
                                //proxy.scrollTo(newValue.id, anchor: .center)
                            }
                        
                        HStack {
                            jumpToTopButton(proxy)
                            
                            jumpToBottomButton(proxy)
                        }
                        
                    }
                    
                    
                    EditorView(viewController.selectedEntry)
                }
                
                
                
                
                
                
                
                
                
                
                
                
                
                //                ScrollViewReader { proxy in
                //                    AccountTableView(selectedAccount: viewModel2.selectedAccount,
                //                                     isBlurred: $isBlurred)
                //                        .conditionalBlurStyle(isBlurred)
                //                        .disabled(isBlurred)
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
        }
        .searchable(text: $searchTerm, prompt: "Search notes")
        .navigationTitle("\(viewController.selectedAccount?.name ?? "")")
        .onChange(of: viewController.selectedAccount?.name, { oldValue, newValue in
            print("account changed")
        })
        //.onDrop(of: AccountDropDelegate.allowedTypes, delegate: AccountDropDelegate())
        .fileImporter(isPresented: $isBlurred, allowedContentTypes: [.data], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let files):
                files.forEach { file in
                    // gain access to the directory
                    let gotAccess = file.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    // access the directory URL
                    // (read templates in the directory, make a bookmark, etc.)
                    do {
                        let newAccount = try CDAccount.load(moc: viewController.viewContext, from: file, type: .propertyList)
                        viewController.selectedAccount = newAccount
                    } catch {
                        fatalError("failed to read .mcb file as .plist: \(error)")
                    }
                    
                    // release access
                    file.stopAccessingSecurityScopedResource()
                }
            case .failure(let error):
                // handle error
                print(error)
            }
            
        }
        .toolbar {
            blurViewButton
            
            createEntryButton
            
            roundTotalsToggle
            
            undoButton
            
            redoButton
        }
        
    }
    
}


extension ContentView {
    func jumpToTopButton(_ proxy: ScrollViewProxy) -> some View {
        Button {
            guard let firstEntry = viewController.selectedAccount?.firstEntry else { return }
            viewController.selectedEntry = firstEntry
            proxy.scrollTo(firstEntry.id, anchor: .center)
        } label: {
            Image(systemName: "arrow.up")
                .padding()
                .background(.regularMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 10.0))
                .shadow(radius: 10)
                .padding([.bottom])
        }.buttonStyle(.plain)
    }
    
    func jumpToBottomButton(_ proxy: ScrollViewProxy) -> some View {
        Button {
            guard let lastEntry = viewController.selectedAccount?.lastEntry else { return }
            viewController.selectedEntry = lastEntry
            proxy.scrollTo(lastEntry.id, anchor: .center)
        } label: {
            Image(systemName: "arrow.down")
                .padding()
                .background(.regularMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 10.0))
                .shadow(radius: 10)
                .padding([.bottom, .trailing])
        }.buttonStyle(.plain)
    }
    
    var blurViewButton: some View {
        Button {
            withAnimation { isBlurred.toggle() }
        } label: {
            Image(systemName: isBlurred ? "eye.slash" : "eye")
        }
        .help("Hide")
    }
    
    var createEntryButton: some View {
        Button {
            if viewController.selectedAccount != nil {
                viewController.createEntry(for: viewController.selectedAccount!)
            }
        } label: {
            Image(systemName: "plus")
        }
        .help("New Entry")
    }
    
    var roundTotalsToggle: some View {
        Toggle("RT", isOn: $useRoundedTotals)
            .help("Round Totals")
            .onChange(of: useRoundedTotals) { _, newValue in
                CDAccountEntry.useRoundedTotals = newValue
            }
    }
    
    var undoButton: some View {
        Button {
            viewController.undo()
        } label: {
            Image(systemName: "arrow.uturn.backward")
        }
        .help("Undo")
        .keyboardShortcut(KeyEquivalent("z"), modifiers: .command)
    }
    
    var redoButton: some View {
        Button {
            viewController.redo()
        } label: {
            Image(systemName: "arrow.uturn.forward")
        }
        .help("Redo")
    }
}
