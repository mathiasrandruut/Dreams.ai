//ISSUES:
// Calendar view is not functional. I do not even need it now i feel like. Or it could be an optional view. But some people journal every day, some do it one a year.
// subscription not functional
// stats in the userview not functional
// weird scaling errors on iphone signup view
// usernames not working
// sign up and sign in error messages not shown nicely, or when i register with a wrong email and then try new email
// keyboard should dissappear when i press log in or sign up button
// intro page for first time sign in
// courses

import SwiftUI
import CoreData

struct MainView: View {
    @State private var dreamText = ""
    @AppStorage("successRequestCount") private var successRequestCount = 0
    @EnvironmentObject var connector: OpenAIConnector
    @State private var responseText = "" // Store the response text
    @State private var isResponseVisible = false // Control the visibility of the response
    @State private var isButtonEnabled = true
    
    // Inject the managed object context into the view
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // Create a DateFormatter with the desired date format
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMMM yyyy"
        return formatter
    }()
    
    // Get the current date as a formatted string
    private var currentDate: Date {
        return Date()
    }
    
    // Key to store the last press date in UserDefaults
    private let lastPressDateKey = "LastPressDate"
    
    // Check if a button press is allowed today
    private var isButtonPressAllowed: Bool {
        if let lastPressDate = UserDefaults.standard.object(forKey: lastPressDateKey) as? Date {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: currentDate)
            let lastPressedDay = calendar.startOfDay(for: lastPressDate)
            
            return true//!calendar.isDate(today, inSameDayAs: lastPressedDay)
        }
        return true
    }
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(uiImage: UIImage(named: "dream.jpg") ?? UIImage())
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        NavigationLink(destination: UserView(successRequestCount: $successRequestCount)) {
                            Image(systemName: "person.circle")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        NavigationLink(destination: CalendarView()) {
                            Image(systemName: "calendar.circle")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    .offset(x: -15, y: -10)
                    
                    Text(dateFormatter.string(from: currentDate))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                    Text("What did you dream today?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()

                    TextField("Three monkeys slept on my couch...", text: $dreamText, axis: .vertical)
                        .lineLimit(6, reservesSpace: true)
                        .font(.title3)
                        .opacity(1)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 35)

                        
                    if isButtonPressAllowed {
                        Button(action: {
                            // Disable the button immediately
                            withAnimation {
                                isButtonEnabled = false
                            }
                            // Hide the keyboard
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

                            // Run the time-consuming task asynchronously
                            DispatchQueue.global(qos: .userInitiated).async {
                                // Check if button press is allowed today
                                // Proceed with the button action
                                // Store the current date as the last press date
                                UserDefaults.standard.set(currentDate, forKey: lastPressDateKey)
                                
                                connector.logMessage(dreamText, messageUserType: .user)
                                connector.sendToAssistant()
                                
                                print("messageLog")
                                // Iterate through and print each message in the log
                                for message in connector.messageLog {
                                    print("Role: \(message["role"] ?? "No role"), Content: \(message["content"] ?? "No content")")
                                    if message["role"] == "assistant" {
                                        responseText = message["content"] ?? ""
                                        isResponseVisible = true
                                        successRequestCount += 1
                                        
                                        // save dream entry
                                        CoreDataManager.shared.addDreamEntry(dreamInput: dreamText, dreamInterpretation: responseText, date: currentDate, userEmail: "info@mathiasrandruut.com") { success, error in
                                            if success {
                                                print("Dream entry saved successfully!")
                                            } else if let error = error {
                                                print("Error saving dream entry: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                }
                                // Once the task is completed, enable the button and show the response
                                DispatchQueue.main.async {
                                    isButtonEnabled = true
                                }
                            }
                        }) {
                            Text(isButtonEnabled && isButtonPressAllowed ? "Tell me the meaning" : "Give me a second...")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isButtonPressAllowed ? Color.accentColor : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(40)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 25)

                    } else {
                        NavigationLink(destination: UserView(successRequestCount: $successRequestCount)) {
                            Text("Upgrade to Pro or come back tomorrow")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(40)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 25)
                        .padding(.vertical, 25)
                    }

                    if isResponseVisible {
                        // Display the response in a scrollable form
                        ScrollView {
                            Text(responseText)
                                .font(.body)
                                .padding()
                                .foregroundColor(.black) // Adjust text color as needed
                        }
                        .background(Color.white) // Adjust background color as needed
                        .cornerRadius(20)
                        .padding(.horizontal, 35)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
