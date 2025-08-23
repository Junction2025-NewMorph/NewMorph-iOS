//
//  ContentView.swift
//  NewMorph-iOS
//
//  Created by mini on 8/21/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NavigationRouter.self) private var router

    @Query private var items: [Item]

    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    ContentView()
        .environment(NavigationRouter())
        .modelContainer(for: Item.self, inMemory: true)
}
