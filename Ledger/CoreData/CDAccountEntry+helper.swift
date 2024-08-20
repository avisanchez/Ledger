import Foundation
import CoreData
import UniformTypeIdentifiers

extension CDAccountEntry {
    
    var date: Date {
        get { self.date_ ?? Date() }
        set { self.date_ = newValue }
    }
    
    var notes: String {
        get { self.notes_ ?? "" }
        set { self.notes_ = newValue }
    }
    
    var debitAmount: Double {
        get { self.debitAmount_ }
        set { self.debitAmount_ = newValue }
    }
    
    var creditAmount: Double {
        get { self.creditAmount_ }
        set { self.creditAmount_ = newValue }
    }
    
    var uuid: UUID {
        get { self.uuid_ ?? UUID() }
        set { self.uuid_ = newValue }
    }

    
    // neccessary to conform to Identifiable
    var id: UUID { self.uuid }
    
    var sortOrder: Int {
        get { Int(self.sortOrder_) }
        set { self.sortOrder_ = Int64(newValue) }
    }
    
    var isFirst: Bool { self.previous == nil }
    
    var isLast: Bool { self.next == nil }
    
    convenience init(context: NSManagedObjectContext,
                            owner: CDAccount,
                            notes: String = "",
                            debitAmount: Double = 0.0,
                            creditAmount: Double = 0.0,
                            posted: Bool = false) {
        self.init(context: context)
        self.owner = owner
        self.notes = notes
        self.debitAmount = debitAmount
        self.creditAmount = creditAmount
        self.posted = posted
    }
    
    // -- Overridden Functions

    override func awakeFromInsert() {
        self.uuid = UUID()
        self.date = Date()
    }
}
