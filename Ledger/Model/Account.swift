import Foundation
import SwiftData


@Model
class Account: Codable, Identifiable {
    
    @Attribute(.unique)
    let id: UUID
    
    var name: String
    
    @Relationship(deleteRule: .cascade)
    var entries: [AccountEntry]
    
    init(id: UUID = UUID(), name: String = "", entries: [AccountEntry] = []) {
        
        self.id = id
        self.name = name
        self.entries = entries
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(UUID.self, forKey: .AccountID) ?? UUID()
        self.name = try container.decodeIfPresent(String.self, forKey: .AccountName) ?? ""
        self.entries = try container.decode([AccountEntry].self, forKey: .AccountEntries)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .AccountID)
        try container.encode(self.name, forKey: .AccountName)
        try container.encode(self.entries, forKey: .AccountEntries)
    }
    
    private enum CodingKeys: String, CodingKey {
        case AccountID
        case AccountName
        case AccountEntries
    }
}
