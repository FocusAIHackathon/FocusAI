//
//  FocusAIApp.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import SwiftUI

@main
struct FocusAIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
