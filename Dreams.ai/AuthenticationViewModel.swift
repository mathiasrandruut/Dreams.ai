import Foundation
import FirebaseAuth
import CoreData

class AuthenticationViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var isRegistered = false
    @Published var errorMessage: String?
    
    private let sessionManager = SessionManager.shared
    
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                self.errorMessage = self.handleAuthError(error)
                completion(false)
            } else if let _ = authResult?.user {
                Auth.auth().currentUser?.sendEmailVerification { error in
                    if let error = error {
                        self.errorMessage = "Error sending verification email: \(error.localizedDescription)"
                        completion(false)
                    } else {
                        CoreDataManager.shared.saveOrUpdateUser(email: email) { success, error in
                            if success {
                                self.isRegistered = true
                                completion(true)
                            } else {
                                self.errorMessage = error?.localizedDescription ?? "Failed to save user data"
                                completion(false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                self.errorMessage = self.handleAuthError(error)
                completion(false)
            } else if let user = Auth.auth().currentUser, user.isEmailVerified {
                self.isSignedIn = true
                CoreDataManager.shared.saveOrUpdateUser(email: email) { success, error in
                    if success {
                        completion(true)
                    } else {
                        self.errorMessage = error?.localizedDescription ?? "Failed to update user last active status"
                        completion(false)
                    }
                }
            } else {
                self.errorMessage = "Email not verified. Please check your email."
                completion(false)
            }
        }
    }
    
    private func handleAuthError(_ error: NSError) -> String {
        let errorCode = error.code // Using error.code directly
        switch errorCode {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Invalid password. Please try again."
        case AuthErrorCode.userNotFound.rawValue:
            return "User with these details not found. Please sign up first."
        case AuthErrorCode.userDisabled.rawValue:
            return "Your account has been disabled. Contact support for assistance."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Email address is already in use. Make sure you have verified your account."
        // Add more cases as needed
        default:
            return "Sign-in failed. Please try again."
        }
    }
}

