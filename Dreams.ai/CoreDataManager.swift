import CoreData
import UIKit
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "dreamModel")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func addDreamEntry(dreamInput: String, dreamInterpretation: String?, date: Date, userEmail: String, completion: @escaping (Bool, Error?) -> Void) {
        let newDreamEntry = DreamEntryEntity(context: context)
        newDreamEntry.dreamInput = dreamInput
        newDreamEntry.dreamInterpretation = dreamInterpretation
        newDreamEntry.dreamDate = date
        
        let userFetchRequest: NSFetchRequest<UserDataEntity> = UserDataEntity.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "email == %@", userEmail)
        
        do {
            let users = try context.fetch(userFetchRequest)
            if let user = users.first {
                user.addToDreamEntries(newDreamEntry)
                try context.save()
                completion(true, nil)
            } else {
                // Handle the case where the user wasn't found
                completion(false, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
            }
        } catch {
            completion(false, error)
        }
    }
}
