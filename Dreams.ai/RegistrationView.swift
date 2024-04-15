import SwiftUI

struct RegistrationView: View {
    // Input fields
    @Binding var name: String
    @State private var email = ""
    @State private var password = ""
    
    // ViewModel for authentication
    @ObservedObject var authViewModel = AuthenticationViewModel()
    
    // State to control the navigation and message displays
    @State private var showConfirmationMessage = false
    @State private var isShowingMainView = false // For modal presentation
    @State private var showErrorMessage = false
    @State private var isLoading = false // Loading state

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "back.jpg") ?? UIImage())
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.vertical)
                .offset(x: -20, y: 0)
            
            VStack {
                Spacer()
                
                Text("Ok, \(name). Enter your email and a password.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding(.vertical, 10)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .textContentType(.password)
                    .padding(.vertical, 10)
                    .cornerRadius(40)
                
                Button(action: {
                    isLoading = true // Set loading state to true
                    
                    authViewModel.signUp(email: email, password: password) { success in
                        isLoading = false // Reset loading state
                        
                        if success {
                            showConfirmationMessage = true
                            showErrorMessage = false
                            // If you wish to navigate to MainView upon successful registration, uncomment below
                            // isShowingMainView = true
                        } else {
                            authViewModel.signIn(email: email, password: password) { signInSuccess in
                                isLoading = false // Reset loading state
                                
                                if signInSuccess {
                                    isShowingMainView = true
                                    showErrorMessage = false
                                } else {
                                    showConfirmationMessage = false
                                    showErrorMessage = true
                                }
                            }
                        }
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        Text("Continue")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(40)
                    }
                }
                .padding(.horizontal)
                
                VStack {
                    if showConfirmationMessage {
                        Text("Registration Successful! Please confirm your email.")
                            .foregroundColor(.green)
                            .padding(.top, 10)
                            .multilineTextAlignment(.center)
                    }
                    
                    if showErrorMessage {
                        Text(authViewModel.errorMessage ?? "Email or password is incorrect")
                            .foregroundColor(.red)
                            .padding()
                            .bold()
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .sheet(isPresented: $isShowingMainView) {
                MainView()
            }
        }
    }
}

