//
//  AppDelegate.swift
//  Dreams.ai
//
//  Created by Mathias Randrüüt on 09.09.2023.
//

import Foundation
import UIKit
import FirebaseCore

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
