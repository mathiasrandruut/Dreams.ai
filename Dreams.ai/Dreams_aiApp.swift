import SwiftUI
import Firebase

@main
struct Dreams_aiApp: App {
    // Initialize Firebase
    init() {
        FirebaseApp.configure()
    }
    
    // Create an object for the OPENAI connection
    @StateObject private var openAIConnector = OpenAIConnector()
    @StateObject private var sessionManager = SessionManager.shared // Use SessionManager as a state object
    
    let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            // Determine which view to show based on the authentication state
            if sessionManager.isLoggedIn {
                OpeningView()
                    .environmentObject(openAIConnector) // Pass OpenAIConnector as an environment object
                    .environment(\.managedObjectContext, coreDataManager.persistentContainer.viewContext) // Pass managed object context
                // User is signed in, show MainView
                // MainView()
                //    .environmentObject(openAIConnector) // Pass OpenAIConnector as an environment object
                //    .environment(\.managedObjectContext, coreDataManager.persistentContainer.viewContext) // Pass managed object context
            } else {
                // User is not signed in, show OpeningView
                OpeningView()
                    .environmentObject(openAIConnector) // Pass OpenAIConnector as an environment object
                    .environment(\.managedObjectContext, coreDataManager.persistentContainer.viewContext) // Pass managed object context
            }
        }
    }
}

