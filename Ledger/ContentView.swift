//
//  ContentView.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/8/24.
//

import Foundation
import SwiftUI


struct ContentView: View {
    
    @State private var viewModel = AccountViewModel()
    
    @State private var tempEntry: AccountEntry
    @State private var isBlurred: Bool
    @State private var selected: Set<AccountEntry.ID>
    @State private var searchTerm: String
    
    
    private var df = DateFormatter()
    private var nf = NumberFormatter()
    
    init() {
        df.dateFormat = "dd/MM/yyyy"
        nf.numberStyle = .decimal
        nf.currencyCode = "USD"
        
        self._tempEntry = State(initialValue: AccountEntry())
        self._isBlurred = State(initialValue: false)
        self._selected = State(initialValue: [])
        self._searchTerm = State(initialValue: "")
    }
    
    
    enum SideBarItem: String, Identifiable, CaseIterable {
        var id: String { rawValue }
        
        case users
        case animals
        case food
    }
    
    @State private var selectedSidebarItem = SideBarItem.users
    
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        NavigationSplitView( 
            sidebar: {
                
                VStack {
                    List(SideBarItem.allCases, selection: $selectedSidebarItem) { item in
                        NavigationLink(item.rawValue.localizedCapitalized, value: item)
                    }
                    .listStyle(.sidebar)
                    
                    Spacer()
                    
                    Text("Hello")
                }
                
                

        }, detail: {
            VSplitView {
                
                ScrollViewReader { proxy in
                    AccountTableView(selected: $selected)
                        .environment(viewModel)
                        .searchable(text: $searchTerm, prompt: "Search notes")
                        .blur(radius: isBlurred ? 5 : 0)
                        .disabled(isBlurred)
                        .onAppear {
                            
                            guard let lastEntry = viewModel.accountEntries.last else { return }
                            
                            proxy.scrollTo(lastEntry.id)
                        }
                        .onSubmit(of: .search) {
                            guard let id = viewModel.searchFor(searchTerm) else { return }
                            
                            selected.removeAll()
                            selected.insert(id)
                            proxy.scrollTo(id, anchor: .center)
                        }
                }
                
                
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        Text("Date")
                            .font(.caption2)
                            .underline()
                            .bold()
                        TextField("Enter Date", value: $tempEntry.date, formatter: df)
                    }
                    
                    
                    VStack(alignment: .leading) {
                        Text("Details")
                            .font(.caption2)
                            .underline()
                            .bold()
                        TextField("Enter Details", text: $tempEntry.notes)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Debit Amount")
                            .font(.caption2)
                            .underline()
                            .bold()
                        
                        TextField("Enter Debit Amount", value: $tempEntry.debitAmount, formatter: nf)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Credit Amount")
                            .font(.caption2)
                            .underline()
                            .bold()
                        
                        TextField("Enter Credit Amount", value: $tempEntry.creditAmount, formatter: nf)
                    }
                    
                    
                    VStack(spacing: 10) {
                        Button {
                            
                        } label: {
                            Image(systemName: "arrow.up")
                        }
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "arrow.down")
                        }

                    }
                    .bold()
    
                }
                .padding()
                .buttonStyle(.plain)
                .background(in: RoundedRectangle(cornerRadius: 10))
                .padding()
                .textFieldStyle(.plain)
                .onChange(of: selected) { _, newValue in
                    guard let entry = viewModel.getFirstSelectedEntry(from: selected) else { return }
                    tempEntry = entry
                }
                .onSubmit(of: .text) {
                    guard let entry = viewModel.getFirstSelectedEntry(from: selected) else { return }
                    viewModel.replace(selected: entry.id, with: tempEntry)
                }
                .blur(radius: isBlurred ? 5 : 0)
                    
                
                
            }
        })
        .navigationTitle("\(viewModel.accountName)")
        .fontDesign(.monospaced)
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
            
            Button {
                guard let entry = viewModel.getFirstSelectedEntry(from: selected) else { return }
                viewModel.insertNewEntryAfter(id: entry.id)
            } label: {
                Image(systemName: "plus")
            }
            
            Toggle("RT", isOn: $viewModel.useRoundedTotals)
        }

        
        
        
    }
    
}


struct AccountTableView: View {
    
    @Environment(AccountViewModel.self) var viewModel: AccountViewModel
    @Binding private var selected: Set<AccountEntry.ID>
    
    init(selected: Binding<Set<AccountEntry.ID>>) {
        self._selected = selected
    }
    
    var body: some View {
        Table(viewModel.accountEntries, selection: $selected) {
            TableColumn("Date") { entry in
                Text(AccountViewModel.formattedDate(entry.date))
            }
            .width(60)
            
            TableColumn("Details") { entry in
                Text(entry.notes)
            }
            .width(min: 100)
            
            TableColumn("Debit") { entry in
                Text(abs(entry.debitAmount), format: .currency(code: "USD"))
                    .opacity(entry.debitAmount.isZero ? 0.1 : 1)
            }
            .width(min: 75)
            
            TableColumn("Credit") { entry in
                Text(abs(entry.creditAmount), format: .currency(code: "USD"))
                    .opacity(entry.creditAmount.isZero ? 0.1 : 1)
            }
            .width(min: 75)
            
            TableColumn("P") { entry in
                Image(systemName: entry.posted ? "checkmark" : "square")
                    .onTapGesture {
                        viewModel.togglePostedStatus(for: entry.id)
                    }
                    .bold()
                
            }
            .width(10)
            
            TableColumn("Total") { entry in
                Text(abs(entry.runningTotal), format: .currency(code: "USD"))
                    .foregroundStyle(entry.runningTotal > 0 ? .red : .primary)
                    .opacity(entry.runningTotal.isZero ? 0.1 : 1)
            }
            .width(min: 75)
            .alignment(.trailing)
            
        }
        .tableStyle(.inset)
        
    }
}

#Preview {
    ContentView()
}
