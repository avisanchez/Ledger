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
    
    @Environment(ViewModel2.self)
    private var viewModel2
    
    
    @Query(FetchDescriptor<Account>(propertiesToFetch: [\.name]),
           animation: .bouncy)
    private var accounts: [Account]
    
    @State private var isEditing: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var selectedAccountID: Account.ID?
    @State private var accountToDeleteID: Account.ID?
        
    private var accountToDeleteName: String {
        guard let accountToDeleteID else { return "" }
        return accounts.first(where: { $0.id == accountToDeleteID })?.name ?? ""
    }
        
    var body: some View {
        
        VStack {
            // -- List of accounts
            List(selection: $selectedAccountID) {
                Section("My Accounts") {
                    ForEach(accounts) { account in
                        
                        if !isEditing {
                            Text(account.name)
                                .contextMenu(
                                    ContextMenu {
                                        Button("Delete") {
                                            initiateDeleteSequence(for: account.id)
                                        }
                                    }
                                )
                        } else {
                            TextField("", text: Bindable(account).name)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    isEditing = false
                                }
                                .contextMenu(
                                    ContextMenu {
                                        Button("Delete") {
                                            initiateDeleteSequence(for: account.id)
                                        }
                                    }
                                )
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            
            // -- Create account button
            Button {
                viewModel2.createAccount()
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
            
            Text("isEditing: \(isEditing)")
                .padding(.bottom)
        }
        // -- Detect delete shortcut
        .onKeyPress(KeyEquivalent("\u{7F}")) {
            guard let selectedAccountID else { return .ignored }
            initiateDeleteSequence(for: selectedAccountID)
            return .handled
        }
        .onKeyPress(.return) {
            isEditing = true
            return .handled
        }
        // -- Confirm account deletion
        .alert("Delete \(accountToDeleteName)?", isPresented: $isShowingAlert) {
            Button("Cancel", role: .cancel) {
                isShowingAlert = false
            }
            Button("Delete") {
                viewModel2.deleteAccount(id: accountToDeleteID)
                
                if selectedAccountID == accountToDeleteID {
                    selectedAccountID = nil
                }
                
                accountToDeleteID = nil
            }
        } message: {
            Text("The account and its associated entries will be deleted from all your devices.")
        }
        .onChange(of: selectedAccountID) { oldValue, newValue in
            viewModel2.selectedAccount = accounts.first(where: { $0.id == newValue })
        }

    }
    
    private func initiateDeleteSequence(for id: Account.ID) {
        self.accountToDeleteID = id
        self.isShowingAlert = true
    }
}
