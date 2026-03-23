//
//  Habit.swift
//  MyHabbitTracker
//
//  Created by Alex on 23.03.2026.
//

import SwiftUI
import SwiftData

@Model
final class Habit {
    var name: String
    var colorHex: String
    var createdAt: Date
    var order: Int
    
    @Relationship(deleteRule: .cascade) var completions: [Completion] = []
    
    init(name: String, colorHex: String = "#000000", order: Int = 0) {
        self.name = name
        self.colorHex = colorHex
        self.order = order
        self.createdAt = Date()
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .black
    }
}
