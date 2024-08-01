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
    @State private var useRoundedTotals: Bool = false
        
    @Binding var selectedAccount: CDAccount?
    @Binding var selectedEntry: CDAccountEntry?
        
    var body: some View {
        
        NavigationSplitView {
            SidebarView(selectedAccount: $selectedAccount)
        } detail: {
            VStack {
                ScrollViewReader { proxy in
                    ZStack(alignment: .bottomTrailing) {
                        
                        VStack {
                            Text("DEBUG")
                            Text("selected entry: \(selectedEntry?.uuid), \(selectedEntry?.sortOrder)")
                            Text("selected account: \(selectedAccount?.name)")
                            TableViewControllerRepresentable(selectedAccount: $selectedAccount,
                                                             selectedEntry: $selectedEntry,
                                                             useRoundedTotals: $useRoundedTotals)
                        }
                       
                        
                        
//                        HStack {
//                            jumpToTopButton(proxy)
//                            
//                            jumpToBottomButton(proxy)
//                        }
                        
                    }
                    
                    EditorView($selectedEntry)
                }
                
            }
        }
//        .onChange(of: selectedAccount) { oldValue, newValue in
//            print("selected account changed")
//        }
        .searchable(text: $searchTerm, prompt: "Search notes")
        .navigationTitle(viewController.selectedAccount?.name ?? "")
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
                        let newAccount = try CDAccount.load(from: file,
                                                            savingTo: viewController.viewContext)
                        viewController.selectedAccount = newAccount
                    } catch {
                        fatalError("\(error)")
                    }
                    
                    
                    // release access
                    file.stopAccessingSecurityScopedResource()
                }
            case .failure(let error):
                // handle error
                fatalError("\(error)")
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
            proxy.scrollTo(firstEntry.id, anchor: .top)
            viewController.selectedEntry = firstEntry
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
            proxy.scrollTo(lastEntry.id, anchor: .bottom)
            viewController.selectedEntry = lastEntry
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
            guard let selectedAccount else { return }
            
            viewController.createEntry(for: selectedAccount)
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
    
    func createEntry() {
        guard let selectedAccount, let selectedEntry else {
            print(#function, "selectedAccount or selectedEntry is nil")
            return
        }
        
        
    }
}
