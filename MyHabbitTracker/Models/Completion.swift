//
//  Completion.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI
import SwiftData

@Model
final class Completion {
    var date: Date
    var habit: Habit?
    
    init(date: Date, habit: Habit) {
        self.date = date
        self.habit = habit
    }
}
