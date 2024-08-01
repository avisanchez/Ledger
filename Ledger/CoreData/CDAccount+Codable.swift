import Foundation
import CoreData
import SwiftUI

final class CDAccount: NSManagedObject, Codable {

    public required convenience init(from decoder: any Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext!] as? NSManagedObjectContext else {
            fatalError("Failed to establish context for CDAccount")
        }
        
        // init self with the obtained context
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try container.decodeIfPresent(UUID.self, forKey: .uuid) ?? UUID()
        self.date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Imported Account"
        
        let sortedEntries = try container.decode(Array<CDAccountEntry>.self, forKey: .entries)
        self.entries = sortedEntries
        
        var sortOrder = 0
        for i in 0..<sortedEntries.count - 1 {
            sortedEntries[i].sortOrder = sortOrder
            sortedEntries[i].next = sortedEntries[i + 1]
            sortOrder += Constants.sortOrderSpacing
        }
        sortedEntries.last?.sortOrder = sortOrder
        
        try context.save()
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uuid, forKey: .uuid)
        try container.encode(date, forKey: .date)
        try container.encode(name, forKey: .name)
        try container.encode(entries, forKey: .entries)
    }
    
    private enum CodingKeys: String, CodingKey {
        
        // Attributes
        case uuid
        case date
        case name
        
        // Relationships
        case entries = "AccountEntries"
    }
}
