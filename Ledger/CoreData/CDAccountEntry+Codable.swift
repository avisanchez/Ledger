import Foundation
import CoreData
import UniformTypeIdentifiers
import SwiftUI

final class CDAccountEntry: NSManagedObject, Codable, Sortable, Transferable {

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
    
    required convenience init(from decoder: any Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext!] as? NSManagedObjectContext else {
            fatalError("Failed to establish context for CDAccount")
        }
        
        // init self with the obtained context
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try container.decodeIfPresent(UUID.self, forKey: .uuid) ?? UUID()
        self.date = try container.decode(Date.self, forKey: .date)
        self.notes = try container.decode(String.self, forKey: .notes)
        self.debitAmount = Double(try container.decode(String.self, forKey: .debitAmount)) ?? 0.0
        self.creditAmount = Double(try container.decode(String.self, forKey: .creditAmount)) ?? 0.0
        self.posted = (try? container.decode(Bool.self, forKey: .posted)) ?? false
        self.sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        self.owner = try container.decodeIfPresent(CDAccount.self, forKey: .owner)
        self.next = try container.decodeIfPresent(CDAccountEntry.self, forKey: .next)
        self.previous = try container.decodeIfPresent(CDAccountEntry.self, forKey: .previous)
    }
    
    public func encode(to encoder: any Encoder) throws { 
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uuid, forKey: .uuid)
        try container.encode(date, forKey: .date)
        try container.encode(notes, forKey: .notes)
        try container.encode(debitAmount, forKey: .debitAmount)
        try container.encode(creditAmount, forKey: .creditAmount)
        try container.encode(posted, forKey: .posted)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encode(owner, forKey: .owner)
        try container.encode(next, forKey: .next)
        try container.encode(previous, forKey: .previous)
    }
    
    private enum CodingKeys: String, CodingKey {
        // Attributes
        case uuid
        case date
        case notes
        case debitAmount
        case creditAmount
        case posted
        case sortOrder = "sortOrder_"
       
        
        // Relationships
        case owner
        case next
        case previous
    }
}
