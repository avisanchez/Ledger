import Foundation
import CoreData
import UniformTypeIdentifiers

extension CDAccount {
    
//    func fetch(predicate: NSPredicate? = nil,
//               sortDescriptors: [NSSortDescriptor]? = nil) throws -> [CDAccount] {
//        let request = Self.fetchRequest()
//        request.predicate = predicate
//        request.sortDescriptors = sortDescriptors
//        
//        guard let managedObjectContext else { return [] }
//        
//        return try managedObjectContext.fetch(request)
//    }
    
    var sortedEntries: [CDAccountEntry] {
        entries?.sortedArray(using: [NSSortDescriptor(key: "sortOrder", ascending: true)]) as? [CDAccountEntry] ?? []
    }
    
    var firstEntry: CDAccountEntry? {
        sortedEntries.first
    }
    
    var lastEntry: CDAccountEntry? {
        sortedEntries.last
    }
    
    public static func load(moc: NSManagedObjectContext, from url: URL, type: UTType) throws -> CDAccount {
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to read data from url")
        }
        
        
        switch type {
        case .json:
            let jsonDecoder = JSONDecoder()
            jsonDecoder.userInfo[CodingUserInfoKey.managedObjectContext!] = moc
            return try jsonDecoder.decode(CDAccount.self, from: data)
        case .propertyList:
            let plistDecoder = PropertyListDecoder()
            plistDecoder.userInfo[CodingUserInfoKey.managedObjectContext!] = moc
            return try plistDecoder.decode(CDAccount.self, from: data)
        default:
            fatalError("\(type) not supported")
        }
    }
    
    public func saveToFile(_ data: CDAccount, _ filename: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            
        do {
            let jsonData = try encoder.encode(data)
            let fileUrl = try FileManager.default
                .url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("\(filename).json")
            try jsonData.write(to: fileUrl)
        } catch {
            fatalError("\(error)")
        }
    }
    
    public override func awakeFromInsert() {
        self.uuid = UUID()
    }
}
