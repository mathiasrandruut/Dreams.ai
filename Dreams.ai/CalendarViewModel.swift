import Foundation
import Combine
import CoreData

class CalendarViewModel: ObservableObject {
    @Published var dreamEntries: [DreamEntryEntity] = []
    private var cancellables: Set<AnyCancellable> = []
    private let coreDataManager: CoreDataManager
    private var userEmail: String

    init(coreDataManager: CoreDataManager, sessionManager: SessionManager) {
        self.coreDataManager = coreDataManager
        self.userEmail = sessionManager.userEmail ?? ""
        
        // Subscribe to changes in the user's email
        sessionManager.$userEmail
            .sink { [weak self] userEmail in
                guard let self = self else { return }
                self.userEmail = userEmail ?? ""
                // Fetch dream entries when the user's email changes
                self.fetchDreamEntries(forDate: Date())
            }
            .store(in: &cancellables)
    }
    
    func fetchDreamEntries(forDate date: Date) {
        coreDataManager.fetchDreamEntries(forUserEmail: userEmail, byDate: date) { [weak self] entries in
            DispatchQueue.main.async {
                self?.dreamEntries = entries
            }
        }
        
    }
}

