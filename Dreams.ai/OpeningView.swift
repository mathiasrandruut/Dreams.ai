import SwiftUI

struct OpeningView: View {
    @State private var name = ""
    @State private var isNavigatingToQuiz = false

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
                    // Title
                    Text("Greetings. What name do you go by in this earthly realm?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 20)

                    // Name input field
                    TextField("Name", text: $name)
                        .lineLimit(2, reservesSpace: true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .padding(.horizontal)
                        .onChange(of: name) { newValue in
                            name = newValue.prefix(1).capitalized + newValue.dropFirst()
                        }

                    // Continue button to navigate to QuizView
                    NavigationLink(destination: QuizView(name: $name), isActive: $isNavigatingToQuiz) {
                        EmptyView()
                    }
                    Button(action: {
                        if !name.isEmpty {
                            // Set the navigation flag to true to navigate to QuizView
                            isNavigatingToQuiz = true
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
                    .padding()
                    .padding(.horizontal)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
