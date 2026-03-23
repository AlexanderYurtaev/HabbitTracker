//
//  HabitTrackerApp.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI
import SwiftData

@main
struct HabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Habit.self, Completion.self])
    }
}
