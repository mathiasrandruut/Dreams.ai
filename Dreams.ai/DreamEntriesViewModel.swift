import Foundation
import Combine
import CoreData

class DreamEntriesViewModel: ObservableObject {
    @Published var dreamEntries: [DreamEntryEntity] = []
    private var cancellables: Set<AnyCancellable> = []
    private let coreDataManager: CoreDataManager
    private let sessionManager: SessionManager
    
    init(coreDataManager: CoreDataManager, sessionManager: SessionManager) {
        self.coreDataManager = coreDataManager
        self.sessionManager = sessionManager
        
        sessionManager.$userEmail
            .compactMap { $0 }
            .sink { [weak self] userEmail in
                self?.fetchDreamEntries(forUserEmail: userEmail, byDate: Date())
            }
            .store(in: &cancellables)
    }
    
    func fetchDreamEntries(forUserEmail userEmail: String, byDate selectedDate: Date) {
        coreDataManager.fetchDreamEntries(forUserEmail: userEmail, byDate: selectedDate) { [weak self] entries in
            DispatchQueue.main.async {
                self?.dreamEntries = entries
            }
        }
    }
    
    func deleteDreamEntry(entry: DreamEntryEntity, completion: @escaping (Bool) -> Void) {
        coreDataManager.deleteDreamEntry(entry: entry) { [weak self] success, _ in
            DispatchQueue.main.async {
                if success {
                    print("Entry deleted successfully.")
                    // Remove the entry from the local list
                    self?.dreamEntries.removeAll { $0 == entry }
                    completion(true)
                } else {
                    print("Failed to delete entry.")
                    completion(false)
                }
            }
        }
    }
}


