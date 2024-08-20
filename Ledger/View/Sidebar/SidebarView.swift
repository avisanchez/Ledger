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
    
    @FetchRequest var accountList: FetchedResults<CDAccount>

    @State var isPresentingDeletionAlert: Bool = false
    @State var isPresentingCreationSheet: Bool = false
    @State var accountToDelete: CDAccount?
    

    @Binding var selectedAccount: CDAccount?
    
    init(selectedAccount: Binding<CDAccount?>) {
        let request = CDAccount.fetchRequest()
        request.sortDescriptors = [.dateOrder]
        request.propertiesToFetch = ["name_", "uuid_"]
        self._accountList = FetchRequest(fetchRequest: request, animation: .bouncy)
        
        self._selectedAccount = selectedAccount
    }
    
    var body: some View {
        
        VStack {
            listOfAccounts
            
            createAccountButton
        }
        
        // -- Detect delete shortcut
        .onKeyPress(.delete) {
            guard let selectedAccount else { return .ignored }
            _initiateDeleteSequence(for: selectedAccount)
            return .handled
        }
        // -- Confirm account deletion
        .alert("Delete \(accountToDelete?.name ?? "")?", isPresented: $isPresentingDeletionAlert) {
            Button("Cancel", role: .cancel) {
                isPresentingDeletionAlert.toggle()
            }
        
            Button("Delete") {
                guard let accountToDelete else { return }
                CDController.delete(accountToDelete)
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
        guard account != .placeholder else { return }
        
        self.accountToDelete = account
        self.isPresentingDeletionAlert.toggle()
    }
}

extension SidebarView {
    
    var listOfAccounts: some View {
        List(selection: $selectedAccount) {
            Section("My Accounts") {
                ForEach(accountList, id: \.self) { account in
                    BindingTextField("",
                                     keyPath: \CDAccount.name,
                                     format: MyEmptyFormatStyle(),
                                     saveChangesOnCommit: true)
                    .environmentObject(account)
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
    }
    
    
    var createAccountButton: some View {
        Button {
            isPresentingCreationSheet.toggle()
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "plus")
                Text("Add Account")
            }
            .fontWeight(.medium)
        }
        .keyboardShortcut(.create)
        .buttonStyle(.borderless)
        .foregroundColor(.accentColor)
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.blue.opacity(0.1))
    }
}
