import Foundation
import CoreData
import SwiftUI

final class CDAccount: NSManagedObject, Codable, Sortable, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: CDAccount.self, contentType: .json)
    }
    
    public required convenience init(from decoder: any Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext!] as? NSManagedObjectContext else {
            fatalError("Failed to establish context for CDAccount")
        }
        
        // init self with the obtained context
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try container.decodeIfPresent(UUID.self, forKey: .uuid) ?? UUID()
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Imported Account"
        self.sortOrder = try container.decodeIfPresent(Double.self, forKey: .sortOrder) ?? 0.0
        let entryArray = try container.decode(Array<CDAccountEntry>.self, forKey: .entries)
        self.entries = NSSet(array: entryArray)
        self.next = try container.decodeIfPresent(CDAccount.self, forKey: .next)
        self.previous = try container.decodeIfPresent(CDAccount.self, forKey: .previous)
        
        
        var localSortOrder: Double = 0
        for i in 0..<entryArray.count - 1 {
            var current = entryArray[i]
            var next = entryArray[i + 1]
            
            // set sortOrder
            current.sortOrder = localSortOrder
            
            // establish connections
            current.next = next
            
            localSortOrder += 1
        }
        entryArray.last?.sortOrder = localSortOrder
        try context.save()
        
        
    }
    
    public func encode(to encoder: any Encoder) throws { 
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uuid, forKey: .uuid)
        try container.encode(name, forKey: .name)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encode(sortedEntries, forKey: .entries)
        try container.encode(next, forKey: .next)
        try container.encode(previous, forKey: .previous)
    }
    
    private enum CodingKeys: String, CodingKey {
        
        // Attributes
        case uuid
        case name
        case sortOrder
        
        // Relationships
        case entries = "AccountEntries"
        case next
        case previous
    }
    
//    private enum MigrationCodingKeys: CodingKeys {
//        
//    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
