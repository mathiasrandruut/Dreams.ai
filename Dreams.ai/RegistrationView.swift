import SwiftUI

struct RegistrationView: View {
    // Input fields
    @Binding var name: String
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    
    // ViewModels for sign-up and sign-in
    @ObservedObject var signupViewModel = SignupViewModel()
    @ObservedObject var signInViewModel = SignInViewModel()
    
    // Binding to show a confirmation message
    @State private var showConfirmation = false
    
    // Binding to navigate to MainView
    @State private var isNavigatingToMainView = false
    
    // Binding to control the error message display
    @State private var showError = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image(uiImage: UIImage(named: "back.jpg") ?? UIImage())
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .offset(x: -20, y: 0)
                
                VStack {
                    Spacer() // Push everything to the top
                    
                    // Title
                    Text("Ok, \(name). Last small step before we can unlock your dreams. Enter your email and create a password.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 20)
                    
                    // Email input field
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .padding(.vertical, 10)
                    
                    // Password input field
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .textContentType(.password)
                        .padding(.vertical, 10)
                        .cornerRadius(40)
                    
                    // Continue/Sign Up button
                    Button(action: {
                        // Attempt to sign up
                        signupViewModel.signUp(email: email, password: password) { success in
                            if success {
                                showConfirmation = true
                                showError = false // Reset the error state
                            } else {
                                // Call the signIn method on signInViewModel instance
                                signInViewModel.signIn(email: email, password: password) { signInSuccess in
                                    // Check if the sign-in was successful before navigating
                                    if signInSuccess {
                                        isNavigatingToMainView = true
                                        showError = false // Reset the error state
                                    } else {
                                        // Unsuccessful login
                                        showConfirmation = false // Hide the confirmation message
                                        showError = true // Set the error state to display the message
                                    }
                                }
                            }
                        }
                    }) {
                        Text("Continue")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(40)
                    }
                    .padding(.horizontal)
                    
                    // Wrap error and confirmation messages in VStack
                    VStack {
                        // Show a message based on the registration status
                        if showConfirmation {
                            Text("Registration Successful! Please confirm your email.")
                                .foregroundColor(.green)
                                .padding(.top, 10)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Display the error message if there is one
                        if showError {
                            Text(signupViewModel.errorMessage ?? "Email or password is incorrect")
                                .foregroundColor(.red)
                                .padding()
                                .bold()
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer() // Push everything to the top
                }
                .padding(.horizontal)
                // Replace "" with EmptyView() or any other view you prefer
                .background(
                    NavigationLink(destination: MainView(), isActive: $isNavigatingToMainView) {
                        EmptyView()
                    }
                )
            }
        }
    }
}

