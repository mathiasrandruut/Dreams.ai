import SwiftUI
struct QuizView: View {
    @Binding var name: String
    @State private var rating: Int?
    @State private var shouldNavigate = false // Added state to control navigation
    
    var body: some View {
        ZStack {
            // Background image
            Image(uiImage: UIImage(named: "back.jpg") ?? UIImage())
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .offset(x: -20, y: 0)
            
            VStack {
                // Display the user's name
                Text("Hello, \(name)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
                    .foregroundColor(.white)
                
                // Ask a question
                Text("Do you overthink a lot in life?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                    .foregroundColor(.white)
                
                // Rating scale
                HStack {
                    ForEach(1...5, id: \.self) { value in
                        Button(action: {
                            // Set the selected rating
                            rating = value
                            shouldNavigate = true // Set the flag to navigate
                        }) {
                            Text("\(value)")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding()
                                .frame(width: 50, height: 50)
                                .background(rating == value ? Color.accentColor : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                    }
                }
                
                Spacer()
                
                // Continue button
                NavigationLink(destination: QuizView2(name: $name), isActive: $shouldNavigate) {
                    EmptyView()
                }
            }
        }
    }
}
