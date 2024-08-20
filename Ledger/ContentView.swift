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
    
    @Environment(ViewController.self) var viewController
    
    @Environment(\.managedObjectContext) var viewContext
    
    @EnvironmentObject var observedSelectedAccount: CDAccount
    
    @State var isBlurred: Bool = false
    @State var searchTerm: String = ""
    
    enum SearchScopes {
        case all
        case byDate
        case byNotes
        case byDebitAmount
        case byCreditAmount
    }
    
    @State var searchScopes: [SearchScopes]?
    
    @State var searchController = SearchController()
    
    var body: some View {
        let viewController = Bindable(viewController)
        
        NavigationSplitView {
            SidebarView(selectedAccount: viewController.selectedAccount)
        } detail: {
            ZStack(alignment: .center) {
                VStack {
                    Text("DEBUG")
                    //                        Text("Searching: \(searchTerm)")
                    //                    Text("selected entry: \(viewController.selectedEntry?.notes)")
                    //                        Text("selected entry: \(selectedEntry?.uuid), \(selectedEntry?.sortOrder)")
                    //                        Text("selected account: \(selectedAccount?.name)")
                    //                        Text("isSearching: \(isSearching)")
                    
                    Button("Print Registered Objects") {
                        print(PersistenceController.shared.viewContext.registeredObjects)
                    }
                    TableViewControllerRepresentable()
                        .environment(searchController)
                        .onKeyPress(.delete) {
                            guard let selectedEntry = self.viewController.selectedEntry else { return .ignored }
                            
                            viewContext.perform {
                                CDController.delete(selectedEntry, useRoundedTotals: self.viewController.useRoundedTotals) { success, newSelf in
                                    guard success else { return }
                                    self.viewController.selectedEntry = newSelf
                                }
                            }
                            
                            return .handled
                        }
                    
                    EditorView(entry: self.viewController.selectedEntry ?? .placeholder)
                }
                .blur(radius: isBlurred ? 5 : 0)
                
            }
            
        }
        
        .searchable(text: $searchTerm, prompt: "Search notes") {
            
            ForEach(searchController.searchSuggestions, id: \.self) { suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
        }
        //        .searchScopes($searchScopes, scopes: {
        //            Text("Search:")
        //                .selectionDisabled()
        //
        //            Text("All").tag(SearchScopes.all)
        //            Text("Date").tag(SearchScopes.byDate)
        //            Text("Notes").tag(SearchScopes.byNotes)
        //
        //        })
        .onSubmit(of: .search) {
            guard let selectedAccount = self.viewController.selectedAccount else { return }
            searchController.submitSearch(selectedAccount, notes: searchTerm)
        }
        .onChange(of: searchTerm, { oldValue, newValue in
            Task {
                searchController.updateSuggestions(from: oldValue, to: newValue)
            }
        })
        .navigationTitle(observedSelectedAccount.name)
        .fileImporter(isPresented: viewController.fileImporterIsPresented,
                      allowedContentTypes: [.json, .propertyList],
                      allowsMultipleSelection: true) { result in
            
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
                                                            savingTo: viewContext)
                        self.viewController.selectedAccount = newAccount
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
            guard let selectedAccount = viewController.selectedAccount else { return }
            let selectedEntry = viewController.selectedEntry
            CDController.createEntry(for: selectedAccount, below: selectedEntry)
        } label: {
            Image(systemName: "plus")
        }
        .keyboardShortcut(.create)
        .help("New Entry")
    }
    
    
    var roundTotalsToggle: some View {
        Toggle("RT", isOn: Bindable(viewController).useRoundedTotals)
            .keyboardShortcut(.roundTotals)
            .help("Round Totals")
    }
    
    
    var undoButton: some View {
        Button {
            // viewController.undo()
            print("TODO: implement undo")
        } label: {
            Image(systemName: "arrow.uturn.backward")
        }
        .keyboardShortcut(.undo)
        .help("Undo")
    }
    
    
    var redoButton: some View {
        Button {
            // viewController.redo()
            print("TODO: implement redo")
        } label: {
            Image(systemName: "arrow.uturn.forward")
        }
        .keyboardShortcut(.redo)
        .help("Redo")
    }
}
