import Foundation
import CoreData
import UniformTypeIdentifiers
import SwiftUI

final class CDAccountEntry: NSManagedObject, Codable, DecodableWithConfiguration {
    
    static var placeholder = CDAccountEntry(entity: CDAccountEntry.entity(), insertInto: nil)
    
    convenience init() {
        self.init(entity: Self.entity(), insertInto: nil)
    }
    
    convenience init(from decoder: any Decoder) throws {
        self.init()
    }
    
    required convenience init(from decoder: any Decoder, configuration version: Double) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext!] as? NSManagedObjectContext else {
            fatalError("Failed to establish context for CDAccount")
        }
        
        // init self with the obtained context
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try container.decodeIfPresent(UUID.self, forKey: .uuid) ?? UUID()
        self.date = try container.decode(Date.self, forKey: .date)
        self.notes = try container.decode(String.self, forKey: .notes)
        switch version {
        case 1.0:
            self.debitAmount = Double(try container.decode(String.self, forKey: .debitAmount)) ?? 0.0
            self.creditAmount = Double(try container.decode(String.self, forKey: .creditAmount)) ?? 0.0
        case 2.0:
            self.debitAmount = try container.decode(Double.self, forKey: .debitAmount)
            self.creditAmount = try container.decode(Double.self, forKey: .creditAmount)
        default:
            break
        }
        
        self.posted = (try? container.decode(Bool.self, forKey: .posted)) ?? false
        self.sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
    }
    
    public func encode(to encoder: any Encoder) throws { 
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.uuid, forKey: .uuid)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.notes, forKey: .notes)
        try container.encode(self.debitAmount, forKey: .debitAmount)
        try container.encode(self.creditAmount, forKey: .creditAmount)
        try container.encode(self.posted, forKey: .posted)
        try container.encode(self.sortOrder, forKey: .sortOrder)
    }
    
    private enum CodingKeys: String, CodingKey {
        // Attributes
        case uuid
        case date
        case notes
        case debitAmount
        case creditAmount
        case posted
        case sortOrder
    }
}
