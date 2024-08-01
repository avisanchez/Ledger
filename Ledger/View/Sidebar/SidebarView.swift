//
//  SidebarView.swift
//  Ledger
//
//  Created by Avi Sanchez on 6/5/24.
//

import Foundation
import SwiftUI
import SwiftData


struct SidebarView: View {
    
    @Environment(ViewController.self)
    private var viewController
    
    @FetchRequest
    private var accounts: FetchedResults<CDAccount>

    @State var isEditing: Bool = false
    @State var isPresentingDeletionAlert: Bool = false
    @State var isPresentingCreationSheet: Bool = false
    @State var accountToDelete: CDAccount?
    
    
    @Binding var selectedAccount: CDAccount?
    
    init(selectedAccount: Binding<CDAccount?>) {
        let request = CDAccount.fetchRequest()
        request.sortDescriptors = [.dateOrder]
        request.propertiesToFetch = ["name_", "uuid_"]
        self._accounts = FetchRequest(fetchRequest: request, animation: .bouncy)
        
        self._selectedAccount = selectedAccount
    }
    
    var body: some View {
        
        VStack {
            // -- List of accounts
            List(selection: $selectedAccount) {
                Section("My Accounts") {
                    ForEach(accounts, id: \.self) { account in
                        SidebarListRowView(for: account,
                                           isSelected: account == selectedAccount,
                                           isEditable: isEditing)
                            .onChange(of: account.name) { viewController.save() }
                            .onChange(of: selectedAccount) { isEditing = false }
                            .contextMenu(menuItems: {
                                Button("New Account...") {
                                    self.isPresentingCreationSheet.toggle()
                                }
                                
                                Divider()
                                
                                Button("Import Account...") {
                                    print("TODO: implement import action")
                                }
                                
                                Button("Export Account...") {
                                    print("TODO: implement export action")
                                }
                                
                                
                                Divider()
                                
                                Button("Delete", role: .destructive) {
                                    _initiateDeleteSequence(for: account)
                                }
                            })
                    }
                }
            }
            .listStyle(.sidebar)
            .onKeyPress(.return) {
                print("return key detected by list")
                isEditing = true
                return .handled
            }
            
            // -- Create account button
            Button {
                isPresentingCreationSheet.toggle()
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: "plus")
                    Text("Add Account")
                }
                .fontWeight(.medium)
            }
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .keyboardShortcut(KeyEquivalent("a"), modifiers: .command)
            .disabled(isEditing)
            
            Button("Print Registered Objects") {
                viewController.printRegisteredObjects()
            }
            .padding(.bottom)
        }
        
        // -- Detect delete shortcut
        .onKeyPress(.delete) {
            if let selectedAccount {
                _initiateDeleteSequence(for: selectedAccount)
            }
            return .handled
        }
        // -- Confirm account deletion
        .alert("Delete \(accountToDelete?.name ?? "")?", isPresented: $isPresentingDeletionAlert) {
            Button("Cancel", role: .cancel) {
                isPresentingDeletionAlert.toggle()
            }
        
            Button("Delete") {
                guard let accountToDelete else { return }
                
                viewController.delete(accountToDelete)
                self.accountToDelete = nil
            }
        } message: {
            Text("The account and its associated entries will be deleted from all your devices.")
        }
        // -- Create new account
        .sheet(isPresented: $isPresentingCreationSheet) {
            CreateAccountFlow()
        }
    }

    func _initiateDeleteSequence(for account: CDAccount) {
        self.accountToDelete = account
        self.isPresentingDeletionAlert.toggle()
    }
}

fileprivate struct SidebarListRowView: View {
    @ObservedObject var account: CDAccount
    @State private var proxyAccountName: String
    @FocusState private var isFocused: Bool
    
    private var isEditing: Bool
    private var isSelected: Bool
    
    init(for account: CDAccount, isSelected: Bool, isEditable: Bool) {
        self.account = account
        self.isEditing = isEditable
        self.isSelected = isSelected
        self._proxyAccountName = State(initialValue: account.name)
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                TextField("", text: $proxyAccountName)
                    .textFieldStyle(.plain)
                    .focusable(isSelected && isEditing)
                    .focused($isFocused)
                
                Text("isFocused: \(isFocused)")
            }
            
        }
        // Saves changes to name when text field loses focus
        .onChange(of: isFocused) { _, newValue in
            guard !newValue else { return }
            account.name = proxyAccountName
        }
        // Responds to changes cause by undo/redo
        .onChange(of: account.name) { _, newValue in
            proxyAccountName = newValue
        }
    }
}
