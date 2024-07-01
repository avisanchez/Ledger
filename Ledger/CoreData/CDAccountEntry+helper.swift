import Foundation
import CoreData

extension CDAccountEntry {
    
    static var useRoundedTotals: Bool = false
    
    var date: Date {
        get {
            self.date_ ?? Date()
        }
        set {
            self.date_  = newValue
        }
    }
    
    var notes: String {
        get {
            self.notes_ ?? ""
        }
        set {
            self.notes_ = newValue
        }
    }
    
    var uuid: UUID {
        get {
            self.uuid_ ?? UUID()
        }
        set {
            self.uuid_ = newValue
        }
    }
    
    var id: UUID {
        uuid
    }
    
    var runningTotal: Double {
        let previousTotal: Double = previous?.runningTotal ?? 0
        
        if Self.useRoundedTotals {
            return previousTotal + debitAmount.rounded(.up) - creditAmount.rounded(.down)
        }
        return previousTotal + debitAmount - creditAmount
    }
    
    var formattedDate: String {
        return DateFormatter.format(date, using: "dd/MM")
    }
    
    var testSortOrder: Double {
        guard let previous else { return 0 }

        return previous.testSortOrder + 1
    }
    
    public convenience init(context: NSManagedObjectContext,
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

    
    
    public override func awakeFromInsert() {
        self.uuid = UUID()
        self.date = Date()
    }
}
