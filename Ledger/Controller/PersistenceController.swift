import CoreData
import Foundation

// Define an observable class to encapsulate all Core Data-related functionality.
class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    static let managedObjectContext: NSManagedObjectContext = shared.persistentContainer.viewContext
    
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
    
    private init() { }
}
