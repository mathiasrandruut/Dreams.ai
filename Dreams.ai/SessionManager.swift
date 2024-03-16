import Foundation
import FirebaseAuth

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        }
    }
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func checkLoggedIn() {
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error as? NSError {
                // Handle the sign-in error
                let errorCode = error.code
                
                switch errorCode {
                case AuthErrorCode.wrongPassword.rawValue:
                    print("Invalid password. Please try again.")
                case AuthErrorCode.userNotFound.rawValue:
                    print("User with these details not found. Please sign up first.")
                case AuthErrorCode.userDisabled.rawValue:
                    print("Your account has been disabled. Contact support for assistance.")
                default:
                    print("Sign-in failed. Please try again.")
                }
                
                completion(false) // Indicate failure in the completion handler
            } else {
                // Sign-in successful
                if let user = Auth.auth().currentUser {
                    if user.isEmailVerified {
                        strongSelf.isLoggedIn = true
                        completion(true) // Indicate success in the completion handler
                    } else {
                        print("Email not verified. Please check your email for a verification link or try signing up again.")
                        completion(false) // Indicate success, but email not verified
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

