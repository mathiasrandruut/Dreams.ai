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
                print("CoreData loading error: \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print("CoreData Store Loaded: \(storeDescription)")
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func addDreamEntry(dreamInput: String, dreamInterpretation: String?, date: Date, userEmail: String, completion: @escaping (Bool, Error?) -> Void) {
        print("Attempting to add a new dream entry...")
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
                print("Dream entry saved successfully.")
                completion(true, nil)
            } else {
                print("User not found, cannot save dream entry.")
                completion(false, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
            }
        } catch {
            print("Error saving dream entry: \(error)")
            completion(false, error)
        }
    }
    
    func saveOrUpdateUser(email: String, completion: @escaping (Bool, Error?) -> Void) {
        print("Attempting to save or update user...")
        let fetchRequest: NSFetchRequest<UserDataEntity> = UserDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let results = try context.fetch(fetchRequest)
            let user: UserDataEntity
            if results.isEmpty {
                user = UserDataEntity(context: context)
                user.email = email
                user.joinedAt = Date()
                print("No existing user found, creating new user with email: \(email)")
            } else {
                user = results.first!
                user.lastActive = Date()  // Assuming lastActive is a property you manage
                print("User found, updating last active date...")
            }

            try context.save()
            print("User saved/updated successfully.")
            completion(true, nil)
        } catch {
            print("Error in saving/updating user: \(error)")
            completion(false, error)
        }
    }
    
    func fetchDreamEntries(forUserEmail email: String, byDate date: Date, completion: @escaping ([DreamEntryEntity]) -> Void) {
        print("Fetching dream entries...")
        let fetchRequest: NSFetchRequest<DreamEntryEntity> = DreamEntryEntity.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "(dreamDate >= %@) AND (dreamDate < %@)", startOfDay as NSDate, endOfDay as NSDate),
            NSPredicate(format: "userRelation.email == %@", email)
        ])

        do {
            let entries = try context.fetch(fetchRequest)
            if entries.isEmpty {
                print("No dream entries found for the specified criteria.")
            } else {
                print("Dream entries fetched successfully: \(entries.count) entries found.")
            }
            completion(entries)
        } catch {
            print("Error fetching dream entries: \(error)")
            completion([])
        }
    }
    
    func deleteDreamEntry(entry: DreamEntryEntity, completion: @escaping (Bool, Error?) -> Void) {
        print("Attempting to delete dream entry...")
        context.delete(entry)

        do {
            try context.save()
            print("Dream entry deleted successfully.")
            completion(true, nil)
        } catch {
            print("Error deleting dream entry: \(error)")
            completion(false, error)
        }
    }
    
    func printCoreDataContents() {
        print("Printing all Dream Entries from Core Data...")
        let fetchRequest: NSFetchRequest<DreamEntryEntity> = DreamEntryEntity.fetchRequest()

        do {
            let entries = try context.fetch(fetchRequest)
            if entries.isEmpty {
                print("No entries to display.")
            } else {
                print("Dream Entries in Core Data:")
                for entry in entries {
                    print("Date: \(entry.dreamDate ?? Date())")
                    print("Input: \(entry.dreamInput ?? "N/A")")
                    print("Interpretation: \(entry.dreamInterpretation ?? "N/A")")
                    print("---")
                }
            }
        } catch {
            print("Error fetching dream entries: \(error)")
        }
    }
}

