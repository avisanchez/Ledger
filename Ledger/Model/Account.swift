//
//  Account.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/9/24.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

class Account: Codable {
    
    var entries: [AccountEntry]
    var useRoundedTotals: Bool
    
    init() {
        self.entries = []
        self.useRoundedTotals = false
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.entries = try container.decode([AccountEntry].self, forKey: .entries)
        self.useRoundedTotals = try container.decode(String.self, forKey: .useRoundedTotals) == "YES" ? true : false
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(entries, forKey: .entries)
        try container.encode(useRoundedTotals, forKey: .useRoundedTotals)
    }
    
    private enum CodingKeys: String, CodingKey {
        case entries = "AccountEntries"
        case useRoundedTotals = "UseRoundedTotals"
    }
}

extension UTType {
    static let accountEntry = UTType(exportedAs: "name.avisanchez.accountEntry")
}

// A payment which affects the running total
@Observable
class AccountEntry: Identifiable, Codable, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .accountEntry)
    }
    
    
    var id: UUID = UUID()
    
    // The date which the transaction took place
    var date: Date
    
    // A brief description of the transaction
    var notes: String
    
    // A payment type which adds to the running total
    var debitAmount: Double
    
    // A payment type which subtracts from the running total
    var creditAmount: Double
    
    // Whether the entry has been recieved by the bank
    var posted: Bool
    
    var runningTotal: Double = 0.0
    
    
    /*
     Initalizes a new transaction to default values
     */
    init() {
        self.date = Date()
        self.notes = ""
        self.debitAmount = 0.0
        self.creditAmount = 0.0
        self.posted = false
    }
    
    
    /*
     Initalizes a new transaction with the provided values
     */
    init(date: Date,
         notes: String,
         debit: Double,
         credit: Double)
    {
        self.date = date
        self.notes = notes
        self.debitAmount = debit
        self.creditAmount = credit
        self.posted = false
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(Date.self, forKey: .date)
        self.notes = try container.decode(String.self, forKey: .notes)
        self.debitAmount = try Double(container.decode(String.self, forKey: .debitAmount)) ?? 0.0
        self.creditAmount = try Double(container.decode(String.self, forKey: .creditAmount)) ?? 0.0
        
        if let posted = try? container.decode(Bool.self, forKey: .posted) {
            self.posted = posted
        }
        else {
            self.posted = false
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(notes, forKey: .notes)
        try container.encode(debitAmount, forKey: .debitAmount)
        try container.encode(creditAmount, forKey: .creditAmount)
        try container.encode(posted, forKey: .posted)
    }

    private enum CodingKeys: String, CodingKey {
        case date
        case notes
        case debitAmount
        case creditAmount
        case posted
    }
    
}
