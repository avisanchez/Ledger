import CoreData
import Foundation

// Define an observable class to encapsulate all Core Data-related functionality.
class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    var viewContext: NSManagedObjectContext {
        self.persistentContainer.viewContext
    }
    
    // Create a persistent container as a lazy variable to defer instantiation until its first use.
    lazy var persistentContainer: NSPersistentContainer = {
        // Pass the data model filename to the container’s initializer.
        let container = NSPersistentContainer(name: "Ledger")
        
        // Load any persistent stores, which creates a store if none exists.
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load peristent stores: \(error.localizedDescription)")
            }
        }
        
        return container
    }()
    
    func save() {
        guard self.persistentContainer.viewContext.hasChanges else { return }

        self.persistentContainer.viewContext.perform {
            do {
                try self.persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save context: \(error)")
            }
        }
    }
    
    private init() { }
}
