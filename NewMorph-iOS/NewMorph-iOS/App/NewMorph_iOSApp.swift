//
//  NewMorph_iOSApp.swift
//  NewMorph-iOS
//
//  Created by mini on 8/21/25.
//

import SwiftUI
import SwiftData

@main
struct NewMorph_iOSApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JournalEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var router = NavigationRouter()
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            NavigationHostView()
                .environment(router)
                .environment(container)
        }
        .modelContainer(sharedModelContainer)
    }
}
