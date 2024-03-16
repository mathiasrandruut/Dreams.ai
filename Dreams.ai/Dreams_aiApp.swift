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
    //create an object for the OPENAI connection
    @StateObject private var openAIConnector = OpenAIConnector()
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            OpeningView()
                .environmentObject(openAIConnector) // Inject the environment object
        }
    }
}
