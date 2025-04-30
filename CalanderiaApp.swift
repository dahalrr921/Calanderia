//
//  CalanderiaApp.swift
//  Calanderia
//
//  
//

import SwiftUI
import SwiftData

@main
struct CalanderiaApp: App {
    @AppStorage("isDarkMode") private var darkMode = false  

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(darkMode ? .dark : .light) 
        }
        .modelContainer(sharedModelContainer)
    }
}
