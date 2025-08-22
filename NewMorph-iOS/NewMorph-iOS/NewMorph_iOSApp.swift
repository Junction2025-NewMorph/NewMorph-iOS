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
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var router = NavigationRouter()

    var body: some Scene {
        WindowGroup {
            NavigationHostView()
                .environment(router)
        }
        .modelContainer(sharedModelContainer)
    }
}
