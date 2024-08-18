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
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @State private var isBlurred: Bool = false
    @State private var searchTerm: String = ""
    
    @Binding var selectedAccount: CDAccount?
    @Binding var selectedEntry: CDAccountEntry?
    
    @EnvironmentObject var testSelectedAccount: CDAccount
    
    
    private enum SearchScopes {
        case all
        case byDate
        case byNotes
        case byDebitAmount
        case byCreditAmount
    }
    
    @State private var searchScopes: [SearchScopes]?
    
    @State private var searchController = SearchController()

    var body: some View {
        
        NavigationSplitView {
            SidebarView(selectedAccount: $selectedAccount)
        } detail: {
            ZStack(alignment: .center) {
                VStack {
                                            Text("DEBUG")
                    //                        Text("Searching: \(searchTerm)")
                                            Text("selected entry: \(selectedEntry?.notes)")
                    //                        Text("selected entry: \(selectedEntry?.uuid), \(selectedEntry?.sortOrder)")
                    //                        Text("selected account: \(selectedAccount?.name)")
                    //                        Text("isSearching: \(isSearching)")
                    TableViewControllerRepresentable()
                        .environment(searchController)
                        .onKeyPress(.delete) {
                            guard let selectedEntry else { return .ignored }
                            
                            viewContext.perform {
                                CDController.delete(selectedEntry, useRoundedTotals: viewController.useRoundedTotals) { success, newSelf in
                                    guard success else { return }
                                    viewController.selectedEntry = newSelf
                                }
                            }
                            
                            return .handled
                        }
                    
                    EditorView(entry: selectedEntry ?? .placeholder)
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
            guard let selectedAccount = viewController.selectedAccount else { return }
            searchController.submitSearch(selectedAccount, notes: searchTerm)
        }
        .onChange(of: searchTerm, { oldValue, newValue in
            Task {
                searchController.updateSuggestions(from: oldValue, to: newValue)
            }
        })
        .navigationTitle(testSelectedAccount.name)
        .fileImporter(isPresented: Bindable(viewController).fileImporterIsPresented,
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
                          
                          Menu {
                              Button("hello world") { }
                              Button("stinky caca") { }
                                  .keyboardShortcut("a")
                          } label: {
                              Image(systemName: "plus")
                          }
                          
                      }
    }
    
}


extension ContentView {
    //    func jumpToTopButton() -> some View {
    //        Button {
    //            guard let firstEntry = viewController.selectedAccount?.firstEntry else { return }
    //            viewController.selectedEntry = firstEntry
    //        } label: {
    //            Image(systemName: "arrow.up")
    //                .padding()
    //                .background(.regularMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 10.0))
    //                .shadow(radius: 10)
    //                .padding([.bottom])
    //        }.buttonStyle(.plain)
    //    }
    
    //    func jumpToBottomButton(_ proxy: ScrollViewProxy) -> some View {
    //        Button {
    //            guard let lastEntry = viewController.selectedAccount?.lastEntry else { return }
    //            proxy.scrollTo(lastEntry.id, anchor: .bottom)
    //            viewController.selectedEntry = lastEntry
    //        } label: {
    //            Image(systemName: "arrow.down")
    //                .padding()
    //                .background(.regularMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 10.0))
    //                .shadow(radius: 10)
    //                .padding([.bottom, .trailing])
    //        }.buttonStyle(.plain)
    //    }
    
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
            CDController.createEntry(for: selectedAccount, below: selectedEntry)
        } label: {
            Image(systemName: "plus")
        }
        .keyboardShortcut(.create)
        .help("New Entry")
    }
    
    var roundTotalsToggle: some View {
        Toggle("RT", isOn: Bindable(viewController).useRoundedTotals)
            .help("Round Totals")
            .keyboardShortcut(.roundTotals)
    }
    
    var undoButton: some View {
        Button {
            viewController.undo()
        } label: {
            Image(systemName: "arrow.uturn.backward")
        }
        .help("Undo")
        .keyboardShortcut(.undo)
        //        .disabled(!viewController.canUndo)
    }
    
    var redoButton: some View {
        Button {
            viewController.redo()
        } label: {
            Image(systemName: "arrow.uturn.forward")
        }
        .help("Redo")
        .keyboardShortcut(.redo)
        //        .disabled(!viewController.canRedo)
    }
}
