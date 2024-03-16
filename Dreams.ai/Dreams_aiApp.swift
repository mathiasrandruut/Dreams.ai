//
//  Dreams_aiApp.swift
//  Dreams.ai
//
//  Created by Mathias Randrüüt on 06.09.2023.
//

import SwiftUI
import Firebase

@main
struct Dreams_aiApp: App {
    // Create an object for the OPENAI connection
    @StateObject private var openAIConnector = OpenAIConnector()
    
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            OpeningView()
                .environmentObject(openAIConnector) // Pass OpenAIConnector as an environment object
                .environment(\.managedObjectContext, coreDataManager.persistentContainer.viewContext) // Pass managed object context
        }
    }
}
