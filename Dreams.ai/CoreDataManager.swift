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
                // Output to console
                print("Saved new dream entry: \(dreamInput), Interpretation: \(dreamInterpretation ?? "No interpretation provided"), Date: \(date)")
            } else {
                // Handle the case where the user wasn't found
                completion(false, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
            }
        } catch {
            completion(false, error)
        }
    }
    
    func saveOrUpdateUser(email: String, completion: @escaping (Bool, Error?) -> Void) {
        let fetchRequest: NSFetchRequest<UserDataEntity> = UserDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let results = try context.fetch(fetchRequest)

            let user: UserDataEntity
            if results.isEmpty {
                // No existing user found, create a new one
                user = UserDataEntity(context: context)
                user.email = email
                user.joinedAt = Date() // Assuming you want to set the joinedAt date here
                // Optionally set other properties for a new user
            } else {
                // Existing user found
                user = results.first!
                // Update properties as needed, for example, lastActive
                user.lastActive = Date()
            }

            // Save the context after adding/updating the user
            try context.save()
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
    
    func fetchDreamEntries(forUserEmail email: String, byDate date: Date, completion: @escaping ([DreamEntryEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<DreamEntryEntity> = DreamEntryEntity.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        // Assuming that `userRelation` is the relationship from DreamEntryEntity to UserDataEntity
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "(dreamDate >= %@) AND (dreamDate < %@)", startOfDay as NSDate, endOfDay as NSDate),
            NSPredicate(format: "userRelation.email == %@", email)
        ])

        do {
            let entries = try context.fetch(fetchRequest)
            completion(entries)
        } catch {
            print("Error fetching dream entries: \(error)")
            completion([])
        }
    }
    
    


}
