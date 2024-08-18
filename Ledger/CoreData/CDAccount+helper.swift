import Foundation
import CoreData
import UniformTypeIdentifiers

extension CDAccount {
    
    var entries: [CDAccountEntry] {
        get {
            guard let entries_ else { return [] }
            return Array(_immutableCocoaArray: entries_)
        }
        set { entries_ = NSSet(array: newValue) }
    }
    
    var sortedEntries: [CDAccountEntry] {
        entries_?.sortedArray(using: [.sortOrder]) as? [CDAccountEntry] ?? []
    }
    
    var firstEntry: CDAccountEntry? {
        sortedEntries.first
    }
    
    var lastEntry: CDAccountEntry? {
        sortedEntries.last
    }
    
    var uuid: UUID {
        get { self.uuid_ ?? UUID() }
        set { self.uuid_ = newValue }
    }
    
    var name: String {
        get { self.name_ ?? "" }
        set {
            self.name_ = newValue
            objectWillChange.send()
        }
    }
    
    var date: Date {
        get { self.date_ ?? Date() }
        set { self.date_ = newValue }
    }
    
    
    public static func load(from url: URL, savingTo moc: NSManagedObjectContext) throws -> CDAccount {
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to read data from url")
        }
        
        let fileType = UTType(filenameExtension: url.pathExtension)
        
        switch fileType {
        case .json:
            let jsonDecoder = JSONDecoder()
            jsonDecoder.userInfo[CodingUserInfoKey.managedObjectContext!] = moc
            return try jsonDecoder.decode(CDAccount.self, from: data)
        case .propertyList:
            let plistDecoder = PropertyListDecoder()
            plistDecoder.userInfo[CodingUserInfoKey.managedObjectContext!] = moc
            return try plistDecoder.decode(CDAccount.self, from: data)
        default:
            fatalError("\(fileType) not supported")
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
    
    convenience init(context: NSManagedObjectContext, name: String) {
        self.init(context: context)
        self.name = name
    }
    
    public override func awakeFromInsert() {
        self.uuid = UUID()
        self.date = Date()
    }
}
