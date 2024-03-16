import Foundation
import FirebaseAuth

class SignupViewModel: ObservableObject {
    @Published var isRegistered = false
    @Published var errorMessage: String?

    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error as NSError? {
                // Handle registration error (e.g., display error message)
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    strongSelf.errorMessage = "Email address is already in use. Make sure you have verified your account."
                } else {
                    strongSelf.errorMessage = "Error creating user: \(error.localizedDescription)"
                }
                print("Error creating user: \(error.localizedDescription)")
                completion(false) // Indicate failure in the completion handler
            } else {
                // User registration successful
                if let user = authResult?.user {
                    // Send email verification
                    user.sendEmailVerification(completion: { [weak self] (error) in
                        guard let strongSelf = self else { return }
                        
                        if let error = error {
                            // Handle the error (e.g., display an error message)
                            print("Error sending verification email: \(error.localizedDescription)")
                        } else {
                            // Verification email sent successfully
                            strongSelf.isRegistered = true
                            completion(true) // Indicate success in the completion handler
                            print("User signed up and verification email sent!")
                        }
                    })
                }
            }
        }
    }
}

