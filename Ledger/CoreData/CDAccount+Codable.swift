import Foundation
import CoreData
import SwiftUI

final class CDAccount: NSManagedObject, Codable {
    
    static var placeholder = CDAccount(entity: CDAccount.entity(), insertInto: nil)
    
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
        
        var _sortedEntries = [CDAccountEntry]()
        if let version = try container.decodeIfPresent(Double.self, forKey: .version) {
            _sortedEntries = try container.decode(Array<CDAccountEntry>.self, forKey: .entries, configuration: version)
        } else {
            _sortedEntries = try container.decode(Array<CDAccountEntry>.self, forKey: .entries, configuration: 1.0)
        }
        self.entries_ = NSSet(array: _sortedEntries)
        
        // set owner, next/previous, sortOrder, runningTotal
        
        var sortOrder = 0
        for i in 0..<_sortedEntries.count {
            let current = _sortedEntries[i]
            let next = _sortedEntries[i + 1]
            
            // set relationships
            current.owner = self
            current.next = next
            
            // set properties
            current.sortOrder = sortOrder
            
            sortOrder += Constants.sortOrderSpacing
        }
        _sortedEntries.last?.sortOrder = sortOrder
        
        context.attemptSave()
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(Constants.encodingVersionNumber, forKey: .version)
        try container.encode(self.uuid, forKey: .uuid)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.sortedEntries, forKey: .entries)
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        // Attributes
        case version
        case uuid
        case date
        case name
        
        // Relationships
        case entries = "AccountEntries"
    }
}
