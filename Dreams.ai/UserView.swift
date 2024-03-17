import Foundation
import SwiftUI

struct UserView: View {
    @Binding var successRequestCount: Int
    // Add an initializer to accept the successRequestCount binding
    init(successRequestCount: Binding<Int>) {
        self._successRequestCount = successRequestCount
    }
    
    @State private var dreamN = ""
    let numberOfLines = 5 // Number of lines to display
    @State private var isNavigatingToMainView = false // Binding for navigation
    @State private var isNavigatingToCalendarView = false // Binding for navigation
    
    // Add a computed property to determine the message
    var dreamCountMessage: String {
        if successRequestCount == 0 {
            return "You have not journaled any dreams yet. Try it out!"
        } else if successRequestCount == 1 {
            return "You have journaled one dream! Good start."
        } else {
            return "You have journaled \(successRequestCount) dreams."
        }
    }

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "user.jpg") ?? UIImage())
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: MainView(), isActive: $isNavigatingToMainView) {
                        Image(systemName: "house.circle")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Button(action: {
                        isNavigatingToCalendarView = true // Activate the navigation to CalendarView
                    }) {
                        Image(systemName: "calendar.circle")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 35) // Add padding to the button
                    .background(NavigationLink("", destination: CalendarView(), isActive: $isNavigatingToCalendarView).opacity(0))
                    // This invisible NavigationLink triggers navigation to CalendarView
                }
                
                Text("@MathiasRandruut")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Text(dreamCountMessage)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)

                Text("Get access to pro features:")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Text("- Unlimited interpretations a day\n - Get an AI generated artwork for each of your dreams\n-Custom notifications for journaling")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)
                    
                // Sign-up button
                Button(action: {
                    //
                }) {
                    Text("Upgrade to pro for just 2.99$ / month")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(40)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 25)
            }
        }
    }
}
