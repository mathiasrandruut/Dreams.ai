import Foundation
import FirebaseAuth
import CoreData

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    @Published var isLoggedIn: Bool = false
    @Published var userEmail: String? = nil
    @Published var isLoading: Bool = false // Added isLoading property

    private let context: NSManagedObjectContext = CoreDataManager.shared.context
    
    init() {
        self.isLoading = true // Set loading state to true when initializing SessionManager
        
        // Add state did change listener to handle login/logout
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            
            if let user = user, user.isEmailVerified {
                // User is signed in and email is verified
                self.isLoggedIn = true
                self.userEmail = user.email
                self.updateUserLastActive(email: user.email ?? "")
            } else {
                // No user is signed in or email is not verified
                self.isLoggedIn = false
                self.userEmail = nil
            }
            
            // Set loading state to false after initial authentication check
            self.isLoading = false
        }
    }
    
    deinit {
        // Remove the listener when SessionManager is deallocated
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            // No need to manually set isLoggedIn or userEmail here as the listener will handle it.
            if let error = error {
                print("Sign in error: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            // No need to manually set isLoggedIn or userEmail here as the listener will handle it.
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    private func updateUserLastActive(email: String) {
        let fetchRequest: NSFetchRequest<UserDataEntity> = UserDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                user.lastActive = Date()
            } else {
                // If the user does not exist, create a new one
                let newUser = UserDataEntity(context: context)
                newUser.email = email
                newUser.joinedAt = Date()
                newUser.lastActive = Date()
            }
            try context.save()
        } catch {
            print("Failed to fetch or save user data: \(error.localizedDescription)")
        }
    }
}

