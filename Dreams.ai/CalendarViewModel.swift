import Foundation
import Combine
import CoreData

class CalendarViewModel: ObservableObject {
    @Published var dreamEntries: [DreamEntryEntity] = []
    private var cancellables: Set<AnyCancellable> = []
    private let coreDataManager: CoreDataManager
    private let sessionManager: SessionManager

    init(coreDataManager: CoreDataManager, sessionManager: SessionManager) {
        self.coreDataManager = coreDataManager
        self.sessionManager = sessionManager

        // Initially fetch entries for the current month
        fetchDreamEntries(for: Date())

        // React to user email changes
        sessionManager.$userEmail
            .sink { [weak self] _ in
                self?.fetchDreamEntries(for: Date()) // Refetch for the current month
            }
            .store(in: &cancellables)
    }

    func fetchDreamEntries(for selectedDate: Date) {
        guard let userEmail = sessionManager.userEmail else { return }
        coreDataManager.fetchDreamEntries(forUserEmail: userEmail, byDate: selectedDate) { [weak self] entries in
            DispatchQueue.main.async {
                self?.dreamEntries = entries.filter {
                    // Filter entries to include only those that match the selected date
                    guard let dreamDate = $0.dreamDate else { return false }
                    return Calendar.current.isDate(dreamDate, inSameDayAs: selectedDate)
                }
            }
        }
    }
}

