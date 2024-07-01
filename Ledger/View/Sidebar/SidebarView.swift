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

    @State private var isEditing: Bool = false
    @State private var isPresentingAlert: Bool = false
    @State private var isPresentingSheet: Bool = false
    @State private var accountToDelete: CDAccount?
        
    @State private var newAccountName: String = ""
    
    @State private var isEditable: Bool = false
    
    init() {
        let request = CDAccount.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        request.propertiesToFetch = ["name", "uuid"]
        self._accounts = FetchRequest(fetchRequest: request, animation: .bouncy)
    }
    
    var body: some View {
        
        VStack {
            
            // -- List of accounts
            List(selection: Bindable(viewController).selectedAccount) {
                Section("My Accounts") {
                    ForEach(accounts, id: \.self) { account in
                        SidebarListRowView(for: account, $isEditing)
                            .contextMenu(
                                ContextMenu {
                                    Button("Delete", role: .destructive) {
                                        initiateDeleteSequence(for: account)
                                    }
                                }
                            )
                            .selectionDisabled(isEditing && account != viewController.selectedAccount)
                    }
                    .onMove { indicies, newOffset in
                        // TODO: Implement reordering
                                                
                        guard let startIndex = indicies.first else { return }
                        withAnimation {
                            viewController.move(CDAccount.self, startIndex, to: newOffset)
                        }
                    }
                    .focusEffectDisabled()
                }
            }
            .listStyle(.sidebar)

            // -- Create account button
            Button {
                isPresentingSheet.toggle()
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: "plus")
                    Text("Add Account")
                }
                .fontWeight(.medium)
            }
            .disabled(isEditing)
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .keyboardShortcut(KeyEquivalent("a"), modifiers: .command)
            
            Button("Print Registered Objects") {
                viewController.printRegisteredObjects()
            }
            .padding(.bottom)
        }
        // -- Detect delete shortcut
        .onKeyPress(.delete) {
            guard let selectedAccount = viewController.selectedAccount else { return .ignored }
            initiateDeleteSequence(for: selectedAccount)
            return .handled
        }
        // -- Confirm account deletion
        .alert("Delete \(accountToDelete?.name ?? "")?", isPresented: $isPresentingAlert) {
            Button("Cancel", role: .cancel) {
                isPresentingAlert.toggle()
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
        .sheet(isPresented: $isPresentingSheet, content: {
            CreateAccountFlow()
        })
        .onKeyPress(.return) {
            if isPresentingSheet { return .ignored }
            
            isEditing.toggle()
            return .handled
        }

    }

    private func initiateDeleteSequence(for account: CDAccount) {
        self.accountToDelete = account
        self.isPresentingAlert.toggle()
    }
}

fileprivate struct SidebarListRowView: View {
    
    @Environment(ViewController.self)
    private var viewController

    @ObservedObject var account: CDAccount
        
    @Binding private var isEditing: Bool
    @FocusState private var isFocused: Bool
    @State private var proxyAccountName: String
            
    init(for account: CDAccount, _ isEditing: Binding<Bool>) {
        self._isEditing = isEditing
        self._proxyAccountName = State(initialValue: account.name ?? "")
        self.account = account
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            TextField("", text: $proxyAccountName)
                .textFieldStyle(.plain)
                .focusable(isEditing)
                .focused($isFocused)

            // DEBUG
//            Text("Sort Order: \(account.sortOrder)")
//            Text("isFocused: \(isFocused)")
//            Text("prev: \(account.previous?.name)")
//            Text("next: \(account.next?.name)")
        }
        // Helps auto focus the text field
        .onChange(of: isEditing) { _, newValue in
            isFocused = newValue && self.account == viewController.selectedAccount
        }
        // Saves changes to name when text field loses focus
        .onChange(of: isFocused) { _, newValue in
            guard !newValue else { return }
            
            account.name = proxyAccountName
            viewController.save()
            
            isEditing = false
        }
        // Responds to changes cause by undo/redo
        .onChange(of: account.name ?? "") { _, newValue in
            proxyAccountName = newValue
        }
    }
}
