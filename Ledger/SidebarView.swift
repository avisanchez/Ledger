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
    //@State private var selectedAccount: Account.ID?
    @State private var accountToDelete: Account.ID?
    
    private var accountToDeleteName: String {
        guard let accountToDelete else { return "" }
        return accounts.first(where: { $0.id == accountToDelete })?.name ?? ""
    }
        
    var body: some View {
        
        VStack {
            // -- List of accounts
            List(selection: Bindable(viewModel2).selectedAccount) {
                Section("My Accounts") {
                    ForEach(accounts) { account in
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
            guard let selectedAccount = viewModel2.selectedAccount else { return .ignored }
            initiateDeleteSequence(for: selectedAccount)
            return .handled
        }
        // -- Confirm account deletion
        .alert("Delete \(accountToDeleteName)?", isPresented: $isShowingAlert) {
            Button("Cancel", role: .cancel) {
                isShowingAlert = false
            }
            Button("Delete", role: .destructive) {
                viewModel2.deleteAccount(id: accountToDelete)
                
                if viewModel2.selectedAccount == accountToDelete {
                    viewModel2.selectedAccount = nil
                }
                
                accountToDelete = nil
            }
        } message: {
            Text("Deleting the account will also erase associated entries which can not be recovered.")
        }
    }
    
    private func initiateDeleteSequence(for id: Account.ID) {
        self.accountToDelete = id
        self.isShowingAlert = true
    }
}
