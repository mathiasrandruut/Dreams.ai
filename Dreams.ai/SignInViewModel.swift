
import Foundation
import FirebaseAuth

class SignInViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var isEmailVerified = false
    @Published var errorMessage = "" // Add a property for error messages

    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error as? NSError {
                // Handle the sign-in error
                let errorCode = error.code
                
                switch errorCode {
                case AuthErrorCode.wrongPassword.rawValue:
                    strongSelf.errorMessage = "Invalid password. Please try again."
                case AuthErrorCode.userNotFound.rawValue:
                    strongSelf.errorMessage = "User with these details not found. Please sign up first."
                case AuthErrorCode.userDisabled.rawValue:
                    strongSelf.errorMessage = "Your account has been disabled. Contact support for assistance."
                default:
                    strongSelf.errorMessage = "Sign-in failed. Please try again."
                }
                
                completion(false) // Indicate failure in the completion handler
            } else {
                // Sign-in successful
                if let user = Auth.auth().currentUser {
                    if user.isEmailVerified {
                        strongSelf.isSignedIn = true
                        strongSelf.isEmailVerified = true
                        completion(true) // Indicate success in the completion handler
                    } else {
                        strongSelf.errorMessage = "Email not verified. Please check your email for a verification link or try signing up again."
                        completion(false) // Indicate success, but email not verified
                    }
                }
            }
        }
    }
}
