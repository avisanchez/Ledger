import Foundation
import SwiftData

// A payment which affects the running total
@Model
class AccountEntry: Identifiable, Codable {
    
    @Attribute(.unique)
    let id: UUID = UUID()
    
    var owner: Account?
    
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
    
    @Transient
    var runningTotal: Double = 0.0
    
    
    /*
     Initalizes a new transaction with the provided values
     */
    init(date: Date = Date(), notes: String = "", debitAmount: Double = 0.0, creditAmount: Double = 0.0, posted: Bool = false) {
        self.date = date
        self.notes = notes
        self.debitAmount = debitAmount
        self.creditAmount = creditAmount
        self.posted = posted
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

    
    private enum CodingKeys: CodingKey {
        case date
        case notes
        case debitAmount
        case creditAmount
        case posted
    }
    
}
